package phucnguyen.com.customlistview;

import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.app.ListActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

public class MainActivity extends Activity {
    String[] names = {"Nguyễn Hữu Phúc", "Nguyễn Khánh Linh", "Lê Thành Nam",
            "Lê Xuân Huy","Hoàng Thu Hồng", "Hồ Sĩ Đức", "Nguyễn Hải Đăng",
            "Nguyễn Hữu Hậu", "Lê Thị Nữ", "Hồ Ngọc Nam"};
    String[] phones = {"0989897973", "0967995843", "0907955843", "0967885811", "0988885231",
            "0908166855", "01215757476", "0919777718", "0974252574","0913641845"};
    Integer[] thumbnails = {R.drawable.man1, R.drawable.wman3, R.drawable.man2,R.drawable.man1,
            R.drawable.wman4, R.drawable.man1, R.drawable.man2, R.drawable.man1,R.drawable.wman4,
            R.drawable.man2};
    TextView txtMsg;
    ListView list;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        txtMsg = findViewById(R.id.txtMsg);
        list = findViewById(R.id.list);

        CustomLabelAdapter adapter = new CustomLabelAdapter(this, R.layout.custom_row_icon_label, names, phones, thumbnails);

        list.setAdapter(adapter);

        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                txtMsg.setText("You choose: " + names[i]);
            }
        });
    }
}