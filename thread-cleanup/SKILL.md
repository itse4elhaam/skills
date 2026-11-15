---
name: thread-cleanup
description: Use this skill whenver the user asks to settle the thread or you conclude/stop/settle the conversation/session. Also use this whenever ~/.agents/skills/conclude-thread is used. 
---

SKIP THIS IF NO non-git artifacts were created during the session

The thread has ended and the conversation is concluded - the user is done with the work.

If the session has created artifacts, these could be html documents, md documents, video files or images - these need to be concluded as well.

If the specific artifact is of tangible value and is non-repro (easily) - treat this with care and upload it to a relevant google drive folder via rclone.

If its not important, confirm from this user by telling them the details and delete them.

The aim is to cleanup temp files and move the important files to cloud while freeing up local space
