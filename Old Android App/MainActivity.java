package com.ipproject.quicprints;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    private ViewPager vPager;
    private FragmentPagerAdapter aPagerAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        vPager = findViewById(R.id.viewPager);

        // associate the adapter with the ViewPager
        aPagerAdapter = new PagerAdapter(getSupportFragmentManager());
        vPager.setAdapter(aPagerAdapter);
        vPager.setCurrentItem(0);
    }


    public static class PagerAdapter extends FragmentPagerAdapter {

        public PagerAdapter(FragmentManager fM) {
            super(fM);
        }

        /*
        *  Gives back the fragment that we want depending on the position of the fragment
        *  i.e. camera might be position 1 and send might be 2 :b
         */
        @Override
        public Fragment getItem(int i) {
            switch(i) {
                case 0:
                    //return the camera fragment
                    return CameraFragment.newInstance();
                case 1:
                    //return the send image fragment
                    return SendFragment.newInstance();
            }
            return null;
        }

        /*
        *  We will have two pagers: one for the sending of the image and one for the taking of it
         */
        @Override
        public int getCount() {
            return 2;
        }
    }
}
