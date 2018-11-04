package com.ipproject.quicprints;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.Camera;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.Toast;

import com.google.firebase.auth.FirebaseAuth;

import java.io.IOException;
import java.util.List;

public class CameraFragment extends Fragment implements SurfaceHolder.Callback {

    private Camera cam;
    private Camera.PictureCallback jPGCallBack;

    private SurfaceHolder liveSurfaceHolder;
    private SurfaceView liveSurfaceView;

    private Button logoutButton;
    private Button capturePhotoButton;

    final int CAMERA_REQUEST_CODE = 1;

    public static CameraFragment newInstance() {
        CameraFragment cFragment = new CameraFragment();
        return cFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_camera, container, false);


        /*
         * holder is what controls the surface view
         * allows us to add something to view
         * like a bridge between camera and view object
         */

        liveSurfaceView = view.findViewById(R.id.surfaceView);
        liveSurfaceHolder = liveSurfaceView.getHolder();

        if(ActivityCompat.checkSelfPermission(getContext(),
                Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                    getActivity(),
                    new String[] {Manifest.permission.CAMERA},
                    CAMERA_REQUEST_CODE);
        } else {
            liveSurfaceHolder.addCallback(this);
            liveSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        }

        logoutButton = view.findViewById(R.id.logoutButton);
        logoutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                LogOut();
            }
        });

        capturePhotoButton = view.findViewById(R.id.captureButton);
        capturePhotoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                captureImage();
            }
        });


        jPGCallBack = new Camera.PictureCallback() {
            /*
            *  Bytes holds all the info of the picture
             */
            @Override
            public void onPictureTaken(byte[] bytes, Camera camera) {
                Intent intent = new Intent(getActivity(), ShowImageTakenActivity.class);
                intent.putExtra("imageBytes", bytes);
                startActivity(intent);
                return;
            }
        };

        return view;
    }

    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
        // need to open the camera (:
        cam = Camera.open();

        Camera.Parameters parameters;
        parameters = cam.getParameters();

        cam.setDisplayOrientation(90);
        parameters.setPreviewFrameRate(30);
        parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE);

        /*
        *  This section will grab all the supported preview sizes and
        *  and find the largest one that we can work with so that the image in the
        *  ShowImageTakenActivity will not display a stretched image
         */
        Camera.Size workingSize;
        List<Camera.Size> camSizes = cam.getParameters().getSupportedPreviewSizes();
        workingSize = camSizes.get(0);

        for(int i = 1; i < camSizes.size(); ++i) {
            if((camSizes.get(i).width * camSizes.get(i).height)
                    > (workingSize.width * workingSize.height)) {
                workingSize = camSizes.get(i);
            }
        }

        parameters.setPreviewSize(workingSize.width, workingSize.height);
        // without this it will not work :/
        cam.setParameters(parameters);

        try {
            cam.setPreviewDisplay(liveSurfaceHolder);
        } catch (IOException e) {
            e.printStackTrace();
        }

        cam.startPreview();
    }


    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {}
    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {}


    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        switch(requestCode) {

            case CAMERA_REQUEST_CODE:
                if(grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {


                    liveSurfaceHolder.addCallback(this);
                    liveSurfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
                } else {
                    Toast.makeText(
                            getContext(),
                            "Please allow permissions",
                            Toast.LENGTH_LONG).show();
                }

        }
    }



    private void captureImage() {
        cam.takePicture(null, null, jPGCallBack);
    }


    private void LogOut() {
        // this will sign out the user, but we need to move them from this page
        FirebaseAuth.getInstance().signOut();

        Intent intent = new Intent(getContext(), SplashScreenActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);

        // this might need to go into a function
        cam.release();
        startActivity(intent);
        return;
    }
}
