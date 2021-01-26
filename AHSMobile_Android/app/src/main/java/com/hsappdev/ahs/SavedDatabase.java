package com.hsappdev.ahs;

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

public class SavedDatabase extends SQLiteOpenHelper {

    /*private static final String TAG = "SavedDatabase";*/

    private static SavedDatabase mInstance;
    public static SavedDatabase getInstance(Context context)
    {
        if(mInstance == null)
        {
            mInstance = new SavedDatabase(context.getApplicationContext());
        }
        return mInstance;
    }
    private SavedDatabase(@Nullable Context context) {
        super(context, current_Table, null, 1);
    }

    private static final String TYPE = "TYPE";
    static final int TYPE_COL = 1;
    private static final String ID = "IDS";
    static final int ID_COL = 2;
    private static final String TIME = "TIME";
    static final int TIME_COL = 3;
    private static final String TITLE = "TITLE";
    static final int TITLE_COL = 4;
    private static final String AUTHOR = "AUTHOR";
    static final int AUTHOR_COL = 5;
    private static final String STORY = "STORY";
    static final int STORY_COL = 6;
    private static final String IPATHS = "IPATHS";
    static final int IPATHS_COL = 7;
    private static final String V_IDS = "V_IDS";
    static final int V_IDS_COL = 8;
    private static final String CATEGORY = "CAT";
    static final int CATEGORY_COL = 9;

    private static final String current_Table = "saved_table";
    private static final int ARTICLE = Article_or_BulletinHolder.Option.ARTICLE.getNum();
    private static final int BULLETIN = Article_or_BulletinHolder.Option.BULLETIN_ARTICLE.getNum();

    @Override
    public void onCreate(SQLiteDatabase db) {
        String createTable =
                "CREATE TABLE " + current_Table +
                        "(ID INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        TYPE + " INTEGER," +
                        ID + " TEXT," +
                        TIME + " INTEGER," + // "INTEGER" different from ints, no overflow despite time being long
                        TITLE + " TEXT," +
                        AUTHOR + " TEXT," +
                        STORY + " TEXT," +
                        IPATHS + " TEXT," +
                        V_IDS + " TEXT," +
                        CATEGORY + " INTEGER);"
        ;
        db.execSQL(createTable);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + current_Table);
        onCreate(db);
    }

    /**
     * Adds a new article to the database
     * @param articles Article
     * @return whether it added successfully to the database
     */
    public boolean add(Article... articles)
    {
        boolean succeeded = true;

        for(Article article: articles)
        {
            ContentValues values = new ContentValues();
            values.put(TYPE, ARTICLE);
            values.put(ID, article.getID());
            values.put(TIME, article.getTimeUpdated());
            values.put(TITLE, article.getTitle());
            values.put(AUTHOR, article.getAuthor());
            values.put(STORY, article.getStory());
            values.put(IPATHS, convertArrayToString(article.getImagePaths()));
            values.put(V_IDS, convertArrayToString(article.getVideoIDS()));
            values.put(CATEGORY, article.getType().getNumCode());

            long result = this.getWritableDatabase().insert(current_Table, null, values);
            succeeded = succeeded && (result != -1);
        }

        // if inserted incorrectly -1 is the return value
        return succeeded;
    }
    public boolean add(Bulletin_Article... articles) {
        boolean succeeded = true;

        for(Bulletin_Article article: articles)
        {
            ContentValues values = new ContentValues();
            values.put(TYPE, BULLETIN);
            values.put(ID, article.getID());
            values.put(TIME, article.getTime());
            values.put(TITLE, article.getTitle());
            values.put(STORY, article.getBodyText());
            values.put(CATEGORY, article.getType().getNumCode());

            long result = this.getWritableDatabase().insert(current_Table, null, values);
            succeeded = succeeded && (result != -1);
        }

        // if inserted incorrectly -1 is the return value
        return succeeded;
    }

    /**
     * Removes the specified article from the database based on id
     * @param id The id of the article to be deleted
     */
    public void deleteByID(String id)
    {
        String query = "DELETE FROM " + current_Table + " WHERE "
                + ID + " = '" + id + "'";
        this.getWritableDatabase().execSQL(query);
    }

    /**
     * Deletes all articles from the database while leaving the database intact
     */
    /*public void deleteAll()
    {
        SQLiteDatabase db = this.getWritableDatabase();
        String query = "DELETE FROM " + current_Table;
        db.execSQL(query);
    }*/

    /**
     * Self Explanatory, but note if for whatever reason there are duplicate ids, it returns the first article only
     * @param ID the id of the article to search for
     * @return null if Article not found, Article if it is found
     */
    /*@Nullable
    public Article_or_BulletinHolder getArticleById(String ID)
    {
        SQLiteDatabase db = this.getWritableDatabase();
        String query = "SELECT * FROM " + current_Table
                + " WHERE  " + SavedDatabase.ID + " = '" + ID + "'";
        Cursor data = db.rawQuery(query, null);

        *//*Log.d(TAG, DatabaseUtils.dumpCursorToString(data));*//*
        if(data.getCount() < 1) // no id found
            return null;

        data.moveToFirst();
        Article_or_BulletinHolder.Option type = Article_or_BulletinHolder.Option.getOptionFromInteger(data.getInt(TYPE_COL));
        if(type == null)
            return null;
        Article_or_BulletinHolder holder;
        switch(type){
            case ARTICLE:
                holder = new Article_or_BulletinHolder(getArticleFromCursor(data));
                break;
            case BULLETIN_ARTICLE:
                holder = new Article_or_BulletinHolder(getBulletin_ArticleFromCursor(data));
                break;
            default:
                throw new IllegalStateException("Unexpected value: " + type);
        }
        data.close();

        return holder;
    }*/

   /* public ArrayList<Article_or_BulletinHolder> getAllArticles()
    {
        SQLiteDatabase db = this.getWritableDatabase();
        String query = "SELECT * FROM " + current_Table;
        Cursor data =  db.rawQuery(query, null);
        ArrayList<Article_or_BulletinHolder> articles = new ArrayList<>();
        while(data.moveToNext())
        {
            Article_or_BulletinHolder.Option type = Article_or_BulletinHolder.Option.getOptionFromInteger(data.getInt(TYPE_COL));

            Article_or_BulletinHolder holder = null;
            if(type != null)
                switch(type){
                    case ARTICLE:
                        holder = new Article_or_BulletinHolder(getArticleFromCursor(data));
                        break;
                    case BULLETIN_ARTICLE:
                        holder = new Article_or_BulletinHolder(getBulletin_ArticleFromCursor(data));
                        break;
                    default:
                        throw new IllegalStateException("Unexpected value: " + type);
                }
            articles.add(holder);
        }
        data.close();
        return articles;
    }*/

    public interface ArticleRetrievedCallback {
        void onArticleLoaded(Article_or_BulletinHolder article);
    }
    public void getAllArticles_withCallBack(ArticleRetrievedCallback callback)
    {
        SQLiteDatabase db = this.getWritableDatabase();
        String query = "SELECT * FROM " + current_Table;
        Cursor data =  db.rawQuery(query, null);

        while(data.moveToNext())
        {
            getSingleSavedArticle(callback, data);
        }
        data.close();

    }

    /**
     * Helper method to get a single article and perform a callback, to avoid duplicate code.
     * @param callback
     * @param data
     */
    private void getSingleSavedArticle(ArticleRetrievedCallback callback, Cursor data){
        Article_or_BulletinHolder.Option type = Article_or_BulletinHolder.Option.getOptionFromInteger(data.getInt(TYPE_COL));

        Article_or_BulletinHolder holder = null;
        if(type != null)
            switch(type){
                case ARTICLE:
                    holder = new Article_or_BulletinHolder(getArticleFromCursor(data));
                    break;
                case BULLETIN_ARTICLE:
                    holder = new Article_or_BulletinHolder(getBulletin_ArticleFromCursor(data));
                    break;
                default:
                    throw new IllegalStateException("Unexpected value: " + type);
            }
        callback.onArticleLoaded(holder);
    }

    /**
     * Similar to getAllArticles_withCallBack() but reverses the order so that the most recently saved articles appear first
     * @param callback
     */
    public void getAllArticlesFromNewest_withCallBack(ArticleRetrievedCallback callback) {
        SQLiteDatabase db = this.getWritableDatabase();
        String query = "SELECT * FROM " + current_Table;
        Cursor data =  db.rawQuery(query, null);
        // Get the number of articles
        int numberOfSavedArticles = data.getCount();
        Log.d("Saved:jeffrey", Integer.toString(numberOfSavedArticles));
        // Move to last index and loop backwards
        // So that newest additions appear first
        data.moveToLast();
        for(int i = numberOfSavedArticles-1; i>=0; i--){
            getSingleSavedArticle(callback, data);
            data.moveToPrevious();
        }
        data.close();
    }

    private static Article getArticleFromCursor(Cursor data){
        return new Article(
                data.getString(ID_COL),
                data.getLong(TIME_COL),
                data.getString(TITLE_COL),
                data.getString(AUTHOR_COL),
                data.getString(STORY_COL),
                convertStringToArray(data.getString(IPATHS_COL)),
                convertStringToArray(data.getString(V_IDS_COL)),
                Article.Type.getTypeFromNumCode(data.getInt(CATEGORY_COL))
        );
    }

    private static Bulletin_Article getBulletin_ArticleFromCursor(Cursor data){
        return new Bulletin_Article(
                data.getString(ID_COL),
                data.getLong(TIME_COL),
                data.getString(TITLE_COL),
                data.getString(STORY_COL),
                Bulletin_Article.Type.getTypeFromNumCode(data.getInt(CATEGORY_COL)),
                true
        );
    }

    /**
     * searches bookmark database if an article is already bookmarked by ID
     * @param id: article ID
     * @return true if bookmark already exists
     */
    public boolean alreadyAdded(String id)
    {
        String selectQuery = "SELECT "+ ID +" FROM " + current_Table +
                " WHERE  " + ID + " = '" + id + "'";
        Cursor cursor = this.getWritableDatabase().rawQuery(selectQuery,null);
        boolean alreadyAdded = cursor.getCount() > 0;
        cursor.close();
        return alreadyAdded;
    }

    /**
     * https://stackoverflow.com/questions/5703330/saving-arraylists-in-sqlite-databases
     * @param str
     * @return
     */
    private static final String JSON_str = "iPaths";
    private static String convertArrayToString(String[] array){
        JSONObject json = new JSONObject();
        JSONArray jsonArray = new JSONArray(new ArrayList<>(Arrays.asList(array)));
        try {
            json.put(JSON_str,jsonArray);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return json.toString();
    }
    private static String[] convertStringToArray(String str){
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
}
