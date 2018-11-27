package com.ipproject.quicprints;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

/*
*  NOTE:
*  Consider making a funciton for going to the different activities
*/

public class LoginRegistrationActivity extends AppCompatActivity {
    private Button loginButton, registerButton;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login_registration);


        // Get access to the Login/Register buttons
        loginButton = findViewById(R.id.loginButton);
        registerButton = findViewById(R.id.registerButton);

        // Set up the on click listeners
        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //use intent to go to the login activity
                Intent intent = new Intent(
                        LoginRegistrationActivity.this,
                        LoginActivity.class);
                startActivity(intent);
                return;
            }
        });

        registerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //use intent to go to the login activity
                Intent intent = new Intent(
                        LoginRegistrationActivity.this,
                        RegistrationActivity.class);
                startActivity(intent);
                return;
            }
        });

    }
}
