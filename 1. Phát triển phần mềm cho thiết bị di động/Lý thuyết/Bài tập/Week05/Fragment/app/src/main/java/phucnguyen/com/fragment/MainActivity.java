package phucnguyen.com.fragment;

import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentTransaction;

import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

public class MainActivity extends FragmentActivity implements MainCallbacks{
    FragmentTransaction ft;
    FragmentRed redFragment;
    FragmentBlue blueFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        // create BLUE fragment - show it
        ft = getSupportFragmentManager().beginTransaction();
        blueFragment = FragmentBlue.newInstance("first-blue");
        ft.replace(R.id.main_holder_blue, blueFragment);
        ft.commit();
        // create Red fragment - show it
        ft = getSupportFragmentManager().beginTransaction();
        redFragment = FragmentRed.newInstance("first-red");
        ft.replace(R.id.main_holder_red, redFragment);
        ft.commit();
    }

    // hàm viết ở main, được gọi ở fragment red và blue -> gởi thông tin về main
    @Override
    public void onMsgFromFragToMain(String sender, String strValue) {

        if (sender.equals("RED-FRAG")){
            try {
                blueFragment.onMsgFromMainToFragment(strValue);
            }
            catch (Exception e) {
                Log.e("ERROR", "onStrFromFragToMain" + e.getMessage());
            }
        }
        if (sender.equals("BLUE-FRAG")){
            try {
                redFragment.onMsgFromMainToFragment(strValue);
            }
            catch (Exception e) {
                Log.e("ERROR", "onStrFromFragToMain" + e.getMessage());
            }
        }
    }
}