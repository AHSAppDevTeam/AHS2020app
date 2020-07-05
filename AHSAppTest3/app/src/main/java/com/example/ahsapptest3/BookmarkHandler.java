package com.example.ahsapptest3;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import androidx.annotation.Nullable;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;

// important note: if there is a weird error (column not found when it exists, for ex) , try clearing all storage on the device/ emulator
// especially when you change the columns somehow in the database
// By Alex Dang

public class BookmarkHandler extends SQLiteOpenHelper {

    private static final String TAG = "BookmarkHandler";

    private static final String TABLE_NAME = "bookmark_table";
    private static final String COL0 = "ID";

    private static final String ART_ID = "ART_ID";
    static final int ID_COL = 1;
    private static final String TIME = "TIME";
    static final int TIME_COL = 2;
    private static final String TITLE = "TITLE";
    static final int TITLE_COL = 3;
    private static final String AUTHOR = "AUTHOR";
    static final int AUTHOR_COL = 4;
    private static final String STORY = "STORY";
    static final int STORY_COL = 5;
    private static final String IPATHS = "IPATHS";
    static final int IPATHS_COL = 6;
    private static final String BMARKED = "BMARKED";
    static final int BMARKED_COL = 7;
    private static final String NOTIF = "NOTIF";
    static final int NOTIF_COL = 8;


    public BookmarkHandler(@Nullable Context context) {
        super(context, TABLE_NAME, null,1);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String createTable =
                "CREATE TABLE " + TABLE_NAME +
                        "(ID INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        ART_ID + " INTEGER," +
                        TIME + " INTEGER," + // "INTEGER" different from ints, no overflow despite time being long
                        TITLE + " TEXT," +
                        AUTHOR + " TEXT," +
                        STORY + " TEXT," +
                        IPATHS + " TEXT," +
                        BMARKED + " INTEGER," + // No booleans in sqlite, store them as integers instead (0 or 1)
                        NOTIF + " INTEGER);"
        ;
        db.execSQL(createTable);
        System.out.println("created table");
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_NAME);
        onCreate(db);
    }

    /**
     * Adds a new article to the database
     * @param article Article
     * @return whether it added successfully to the database
     */
    public boolean add(Article article)
    {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();

        contentValues.put(ART_ID, article.getID());
        contentValues.put(TIME, article.getTimeUpdated());
        contentValues.put(TITLE, article.getTitle());
        contentValues.put(AUTHOR, article.getAuthor());
        contentValues.put(STORY, article.getStory());
        contentValues.put(IPATHS, convertArrayToString(article.getImagePaths()));
        contentValues.put(BMARKED, (article.isBookmarked()) ? 1 : 0);
        contentValues.put(NOTIF, (article.alreadyNotified()) ? 1 : 0);

        long result = db.insert(TABLE_NAME, null, contentValues);

        // if inserted incorrectly -1 is the return value
        return result != -1;
    }

    /**
     * updates a particular article in the database; not complete yet but you get the idea
     * @param article   The new article to replace the old one
     * @param oldId     The id of the old article
     */
    public void update(Article article, int oldId)
    {
        SQLiteDatabase db = this.getWritableDatabase();
        String query = "UPDATE " + TABLE_NAME
                + " SET " + ART_ID + " = '" + article.getID()
                + "' SET " + TIME + " = '" + article.getTimeUpdated()
                + "'' WHERE " + ART_ID + " = '" + article.getID() + "'";
        db.execSQL(query);
    }

    /**
     * Removes the specified article from the database based on id
     * @param article   The article to be deleted
     */
    public void delete(Article article)
    {
        SQLiteDatabase db = this.getWritableDatabase();
        String query = "DELETE FROM " + TABLE_NAME + " WHERE "
                + ART_ID + " = '" + article.getID() + "'";
        db.execSQL(query);
    }

    /**
     *  Returns all the data from database
     */
    public Cursor getAllData()
    {
        SQLiteDatabase db = this.getWritableDatabase();
        String query = "SELECT * FROM " + TABLE_NAME;
        Cursor data = db.rawQuery(query, null);
        return data;
    }

    public ArrayList<Article> getAllArticles()
    {
        Cursor data = getAllData();
        ArrayList<Article> articles = new ArrayList<>();
        while(data.moveToNext())
        {
            articles.add(new Article(
                    data.getInt(ID_COL),
                    data.getLong(TIME_COL),
                    data.getString(TITLE_COL),
                    data.getString(AUTHOR_COL),
                    data.getString(STORY_COL),
                    convertStringToArray(data.getString(IPATHS_COL)),
                    (data.getInt(BMARKED_COL) == 1),
                    (data.getInt(NOTIF_COL) == 1)
            ));
        }
        return articles;
    }

    /**
     * searches bookmark database if an article is already bookmarked by ID
     * @param id: article ID
     * @return true if bookmark already exists
     */
    public boolean alreadyBookmarked(int id)
    {
        SQLiteDatabase db = this.getWritableDatabase();
        String selectQuery = "SELECT "+ ART_ID +" FROM " + TABLE_NAME + " WHERE  " + ART_ID + " = '" + id + "'";
        Cursor cursor = db.rawQuery(selectQuery,null);
        return cursor.getCount() > 0;
    }

    /**
     * https://stackoverflow.com/questions/9053685/android-sqlite-saving-string-array
     * A temp soln better to muck about with JSON: (did that already)
     * https://stackoverflow.com/questions/5703330/saving-arraylists-in-sqlite-databases
     * @param str
     * @return
     */
    /*private static final String strSeparator = "__,__";*/
    private static final String JSON_str = "iPaths";
    private static String convertArrayToString(String[] array){
        JSONObject json = new JSONObject();
        JSONArray jsonArray = new JSONArray(new ArrayList<>(Arrays.asList(array)));
        try {
            json.put(JSON_str,jsonArray);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        String str = json.toString();
        /*String str = "";
        for (int i = 0;i<array.length; i++) {
            str = str+array[i];
            // Do not append comma at the end of last element
            if(i<array.length-1){
                str = str+strSeparator;
            }
        }*/
        return str;
    }
    private static String[] convertStringToArray(String str){
        /*String[] arr = str.split(strSeparator);*/
        JSONObject json = null;
        try {
            json = new JSONObject(str);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        JSONArray jsonArray = json.optJSONArray(JSON_str);
        String[] strArr = new String[jsonArray.length()];
        for(int i = 0; i < jsonArray.length(); i++)
            strArr[i] = jsonArray.optString(i);

        return strArr;
    }

    // to help keep track of bookmark changes so that onResume() activities display bookmark icons correctly
    private static boolean bookmarkChanged = false;

    /**
     * By default sets bookmarkChanged to true
     */
    public static void setBookmarkChanged()
    {
        bookmarkChanged = true;
    }
    public static boolean hasBookmarksChanged()
    {
        boolean holder = bookmarkChanged;
        bookmarkChanged = false; // once this method is called, it is assumed bookmark changes are taken care of
        return holder;
    }
}
