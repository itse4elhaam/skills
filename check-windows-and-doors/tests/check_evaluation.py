#!/usr/bin/env python3
"""Compare independent forward-test decisions with the regression cases.

Give an evaluator only id/request fields from evaluation-cases.json and the skill.
It writes a JSON array with id, decision, reason, and next_actions. Pass that file
here. This checks completion decisions, not the truth of an actual security audit.
Review reasons/actions against the rubric in evaluation.md as well.
"""
import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('results', type=Path)
    args = parser.parse_args()
    cases = json.loads(Path(__file__).with_name('evaluation-cases.json').read_text())
    results = json.loads(args.results.read_text())
    by_id = {}
    failures = []
    for result in results:
        case_id = result['id']
        if case_id in by_id:
            failures.append(f'{case_id}: duplicate result')
        by_id[case_id] = result
    expected_ids = {case['id'] for case in cases}
    for extra in by_id.keys() - expected_ids:
        failures.append(f'{extra}: unexpected result')
    for case in cases:
        result = by_id.get(case['id'])
        if result is None:
            failures.append(f"{case['id']}: missing result")
            continue
        if result.get('decision') != case['expected']:
            failures.append(f"{case['id']}: expected {case['expected']}, got {result.get('decision')}")
        if not result.get('reason') or not result.get('next_actions'):
            failures.append(f"{case['id']}: reason and next_actions required")
    if failures:
        print('\n'.join(failures))
        raise SystemExit(1)
    print(f'{len(cases)} completion decisions passed; manually review reasons and actions.')


if __name__ == '__main__':
    main()
