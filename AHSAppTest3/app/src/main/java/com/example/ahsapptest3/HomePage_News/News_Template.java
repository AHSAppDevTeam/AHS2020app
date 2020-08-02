package com.example.ahsapptest3.HomePage_News;

import android.os.Bundle;
import android.os.Parcelable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.fragment.app.Fragment;

import com.example.ahsapptest3.Article;
import com.example.ahsapptest3.Helper_Code.EnhancedWrapContentViewPager;
import com.example.ahsapptest3.R;
import com.google.android.material.tabs.TabLayout;

import java.util.Arrays;


/**
 * A simple {@link Fragment} subclass.
 */

public class News_Template extends Fragment {

    private static final String TAG = "News_Template";
    public News_Template() {
        // Required empty public constructor
    }

    private EnhancedWrapContentViewPager viewPager;
    private Article[] articles;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.news_template, container, false);

        if(getArguments() == null)
            return view;

        TextView titleText = view.findViewById(R.id.template_news__TitleText);
        titleText.setText(getArguments().getString(TITLE_KEY));

        /*ImageView titleBar = view.findViewById(R.id.template_news__rounded_bar);
        titleBar.setColorFilter(getArguments().getInt(COLOR_KEY));*/

       /* String[][] data = getData();
        if(data.length == 0) return view;

        Article[] articles = new Article[data.length];
        for(int i = 0; i < articles.length; i++)
        {
            articles[i] = new Article(
                    getDate(""),
                    data[i][0],
                    data[i][1],
                    getImageFilePath(""),
                    isAlreadyBookmarked(""));
        }*/

        Parcelable[] parcelables = getArguments().getParcelableArray(ARTICLE_KEY);

        assert parcelables != null;
        articles = Arrays.copyOf(parcelables,parcelables.length,Article[].class); // attempts to avoid classcastexception


        viewPager = view.findViewById(R.id.template_news__ViewPager);

        viewPager.setAdapter(
                (getArguments().getBoolean(IS_FEATURED))
                ? new FeaturedArticle_PagerAdapter(getChildFragmentManager(),articles)
                : new Article_Stacked_PagerAdapter(getChildFragmentManager(),articles,getNumStacked())
                );
        TabLayout tabLayout = view.findViewById(R.id.template_news__TabLayout);
        tabLayout.setupWithViewPager(viewPager, true);


        return view;
    }

    private final static String // keys for bundle
            ARTICLE_KEY = "1",
            TITLE_KEY = "2",
            IS_FEATURED = "3";
    public static News_Template newInstanceOf(Article[] articles, final String title, final boolean isFeatured)
    {
        News_Template thisFrag = new News_Template();
        Bundle args = new Bundle();
        args.putParcelableArray(ARTICLE_KEY,articles);
        args.putString(TITLE_KEY,title);
        args.putBoolean(IS_FEATURED, isFeatured);
        thisFrag.setArguments(args);

        return thisFrag;
    }


    private static int getNumStacked()
    {
        return 2;
    }

}
