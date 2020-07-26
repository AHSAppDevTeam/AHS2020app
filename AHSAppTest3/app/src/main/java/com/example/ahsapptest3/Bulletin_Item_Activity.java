package com.example.ahsapptest3;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.example.ahsapptest3.Helper_Code.Helper;

public class Bulletin_Item_Activity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bulletin_article_layout);

        Bulletin_Data data = getIntent().getParcelableExtra("data");
        TextView
                dateText = findViewById(R.id.bulletin_article_dateText),
                titleText = findViewById(R.id.bulletin_article_titleText),
                bodyText = findViewById(R.id.bulletin_article_bodyText),
                typeText = findViewById(R.id.bulletin_article_type_text);

        if(data != null)
        {dateText.setText(Helper.DateFromTime("MMMM dd, yyyy", data.getTime()));
        titleText.setText(data.getTitle());
        Helper.setHtmlParsedText_toView(bodyText, data.getBodyText());
        typeText.setText(data.getType().getName());

        // set listener for back button
        ImageButton backButton = findViewById(R.id.bulletin_article_header_back);
        backButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });}
    }
}