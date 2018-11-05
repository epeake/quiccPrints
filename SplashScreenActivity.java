package com.ipproject.quicprints;

import android.content.Intent;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;

import com.google.firebase.auth.FirebaseAuth;

public class SplashScreenActivity extends AppCompatActivity {

    public static Boolean started = new Boolean(false);
    private FirebaseAuth usrAuth;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // contains all the information associated with the user that is currently logged in
        // id, email, anything in table of database
        usrAuth = FirebaseAuth.getInstance();
        if(usrAuth.getCurrentUser() != null) {
            Intent intent = new Intent(SplashScreenActivity.this, MainActivity.class);
            // before going to main activity clear other activities in case the user logs out or
            // logs in.. it erases the history of those activities
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            return;
        } else {
            Intent intent = new Intent(
                    SplashScreenActivity.this,
                    LoginRegistrationActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            finish();
            return;
        }
    }
}
