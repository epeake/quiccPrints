package com.ipproject.quicprints;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.widget.ImageView;

public class ShowImageTakenActivity extends AppCompatActivity {

    private Bundle extras;
    private ImageView imageContainer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_show_image_taken);
        byte[] imageBytes = null;
        extras = getIntent().getExtras();
        if(extras != null) {
            imageBytes = extras.getByteArray("imageBytes");
        }

        if(imageBytes != null) {
            imageContainer = findViewById(R.id.image);

            Bitmap decodedImage = BitmapFactory.decodeByteArray(
                    imageBytes,
                    0,
                    imageBytes.length);

            /*
            *  If the image is not rotated it comes up in the activity as very stretched
            *  to undo this use the rotate method to (using the same image bytes) rotate
            *  the image and get back a new bitmap.
            */
            Bitmap rotatedImage = rotate(decodedImage);

            imageContainer.setImageBitmap(rotatedImage);
        }
    }

    private Bitmap rotate(Bitmap decodedImage) {

        int width = decodedImage.getWidth();
        int height = decodedImage.getHeight();

        //allows us to rotate the image (:
        Matrix matt = new Matrix();
        matt.setRotate(90);

        DisplayMetrics metrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(metrics);

        matt.postScale(metrics.scaledDensity, metrics.scaledDensity);

        return Bitmap.createBitmap(decodedImage, 0, 0, width, height, matt, true);
    }
}
