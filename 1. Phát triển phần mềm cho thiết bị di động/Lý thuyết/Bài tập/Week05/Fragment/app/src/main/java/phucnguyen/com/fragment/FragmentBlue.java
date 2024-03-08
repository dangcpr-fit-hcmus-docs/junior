package phucnguyen.com.fragment;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

public class FragmentBlue extends Fragment implements FragmentCallbacks {
    MainActivity main;
    Context context = null;
    ListView listView;
    String message ="";
    TextView txtBlue;
    Integer current_position = -1;

    private String items[] = {"A1_5245","A2_3862","A3_4820","A4_9472","A1_4346", "A3_2536","A2_7584","A1_7583","A4_6473","A3_6468"};
    private String[] names = {"Nguyễn Hữu Phúc", "Nguyễn Khánh Linh", "Lê Thành Nam",
            "Lê Xuân Huy","Hoàng Thu Hồng", "Hồ Sĩ Đức", "Nguyễn Hải Đăng",
            "Nguyễn Hữu Hậu", "Lê Thị Nữ", "Hồ Ngọc Nam"};
    private String[] grades = {"8","9.3","5.7","9.6","10","6.8","8.4","7.3","8.9","9.1"};
    private String[] classes = {"A1", "A2", "A3", "A4", "A1", "A3", "A2", "A1", "A4", "A3"};
    private Integer[] thumbnails = {R.drawable.man1, R.drawable.wman3, R.drawable.man2,R.drawable.man1,
            R.drawable.wman4, R.drawable.man1, R.drawable.man2, R.drawable.man1,R.drawable.wman4,
            R.drawable.man2};

    public static FragmentBlue newInstance(String strArg) {
        FragmentBlue fragment = new FragmentBlue();
        Bundle args = new Bundle();
        args.putString("strArg1", strArg);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            context = getActivity(); // use this reference to invoke main callbacks
            main = (MainActivity) getActivity();
        }
        catch (IllegalStateException e) {
            throw new IllegalStateException("MainActivity must implement callbacks");
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        // inflate layout
        LinearLayout layout_blue = (LinearLayout) inflater.inflate(R.layout.layout_blue,null);

        // plumbing textview listview
        txtBlue = (TextView) layout_blue.findViewById(R.id.textView1Blue);
        listView = (ListView) layout_blue.findViewById(R.id.listView1Blue);

        // create list view
        CustomLabelAdapter adapter = new CustomLabelAdapter(context, R.layout.custom_row_icon_label, items, thumbnails);
        listView.setAdapter(adapter);

        // show listview from the top
        listView.setSelection(0); listView.smoothScrollToPosition(0);

        // set on Click
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View v, int position, long id) {
                current_position = position;
                sendMessageToRedFrag();

                listView.smoothScrollToPosition(current_position);

                txtBlue.setText("Mã số: " + items[position]);
            }});
        // do this for each row (ViewHolder-Pattern could be used for better performance!)
        return layout_blue;
    }

    @Override
    public void onMsgFromMainToFragment(String strValue) {
        if ("First" == strValue && current_position != -1) {
            current_position = 0;
            sendMessageToRedFrag();
            listView.setItemChecked(current_position,true);
            listView.smoothScrollToPosition(current_position);

        } else if ("Last" == strValue && current_position != -1) {
            current_position = items.length - 1;
            sendMessageToRedFrag();
            listView.setItemChecked(current_position,true);
            listView.smoothScrollToPosition(current_position);

        } else if ("Next" == strValue && current_position != -1) {

            if (current_position == items.length - 1) {
                current_position = 0;
            }
            else {
                current_position += 1;
            }
            sendMessageToRedFrag();
            listView.setItemChecked(current_position,true);
            listView.smoothScrollToPosition(current_position);

        } else if ("Previous" == strValue && current_position != -1) {
            if (current_position == 0) {
                current_position = items.length - 1;
            }
            else {
                current_position  -= 1;
            }
            sendMessageToRedFrag();
            listView.setItemChecked(current_position,true);
            listView.smoothScrollToPosition(current_position);
        }
    }

    private void sendMessageToRedFrag() {
        Integer maxIndex = items.length - 1;
        message = maxIndex + "-" + current_position + "-" + items[current_position] + "-" + "Họ tên: " + names[current_position] + "\nLớp: " + classes[current_position] + "\nĐiểm trung bình: " + grades[current_position];
        main.onMsgFromFragToMain("BLUE-FRAG", message);
    }

}
