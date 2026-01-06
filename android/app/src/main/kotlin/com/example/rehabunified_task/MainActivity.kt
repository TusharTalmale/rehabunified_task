package com.example.rehabunified_task

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity(){
     override fun onUserLeaveHint() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            enterPictureInPictureMode(
                PictureInPictureParams.Builder().build()
            )
        }
    }
}
