package com.ipproject.quicprints;

import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.HashMap;
import java.util.Map;

public class RegistrationActivity extends AppCompatActivity {

    private EditText firstName, lastName, userName, email, psswrd;
    private Button registerButton;

    private FirebaseAuth usrAuth;
    private FirebaseAuth.AuthStateListener fireBAuthStateListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_registration);

        fireBAuthStateListener = new FirebaseAuth.AuthStateListener() {
            @Override
            public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
                FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                // in case the user is already logged in just redirect to the main
                // this should not happen but in case it does there is a measure taken
                if(user != null) {
                    Intent intent =  new Intent(
                            RegistrationActivity.this,
                            MainActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    startActivity(intent);
                    finish();
                    return;
                }
            }
        };

        usrAuth = FirebaseAuth.getInstance();

        firstName = findViewById(R.id.firstNameEditText);
        lastName = findViewById(R.id.lastNameEditText);
        userName = findViewById(R.id.userNameEditText);
        email = findViewById(R.id.emailEditText);
        psswrd = findViewById(R.id.psswdEditText);

        registerButton = findViewById(R.id.registerButton);
        registerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                final String usrFName = firstName.getText().toString();
                final String usrLName = lastName.getText().toString();
                final String usrName = userName.getText().toString();
                final String usrEmail = email.getText().toString();
                final String usrPass = psswrd.getText().toString();

                usrAuth.createUserWithEmailAndPassword(usrEmail, usrPass).addOnCompleteListener(
                    RegistrationActivity.this, new OnCompleteListener<AuthResult>() {
                        @Override
                        public void onComplete(@NonNull Task<AuthResult> task) {
                            if(!task.isSuccessful()) {
                                Toast.makeText(
                                        RegistrationActivity.this,
                                        "Error signing up",
                                        Toast.LENGTH_SHORT).show();
                            } else {
                                String usrID = usrAuth.getCurrentUser().getUid();
                                //use DB reference to get the child that you want
                                DatabaseReference currUsrDB = FirebaseDatabase.
                                        getInstance().
                                        getReference().
                                        child("users").
                                        child(usrID);

                                Map usrInfo = new HashMap<>();
                                usrInfo.put("email", usrEmail);
                                usrInfo.put("name", usrName);

                                currUsrDB.updateChildren(usrInfo);

                            }
                        }
                    }
                );
            }
        });
    }


    @Override
    protected void onStart() {
        super.onStart();
        usrAuth.addAuthStateListener(fireBAuthStateListener);
    }

    @Override
    protected void onStop() {
        super.onStop();
        usrAuth.removeAuthStateListener(fireBAuthStateListener);
    }
}
