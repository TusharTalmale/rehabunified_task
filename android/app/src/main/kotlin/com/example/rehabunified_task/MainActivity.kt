package com.example.rehabunified_task

// These three imports are required for your code to recognize Android system features
import android.os.Build 
import android.app.PictureInPictureParams
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity(){
     override fun onUserLeaveHint() {
        // Build and PictureInPictureParams now have their "addresses" imported above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            enterPictureInPictureMode(
                PictureInPictureParams.Builder().build()
            )
        }
    }
}