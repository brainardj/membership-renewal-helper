public class SalesforceChapterProductQuery implements IProductQuery{
    String chapter;
    String latitude;
    String longitude;
    Id contactId;
    String city;
    
    public SalesforceChapterProductQuery(){
        AppSettings settings = new AppSettings();
        chapter = (String)settings.get('ChapterQuery.DEFAULT_CHAPTER_LOCATION');
    }
    
    public void setParameters(Map<String,String> params){
        //Maybe this...
        latitude = params.get('latitude');
        longitude = params.get('longitude');
        //Or this to query for the customers city
        contactId = params.get('contactId');
    }
    
    //Use longitude and latitude to determine the chapter
    public String getChapterByLocation(){
        chapter = 'some location';
        return chapter;
    }
    
    public List<IProductBase> getProducts(){
        List<IProductBase> prods;
        prods = doQuery(chapter);
        return prods;
    }
    
    //Query results in a list of products for given chapter
    public List<SalesforceProduct> doQuery(String chapter){
        return new List<SalesforceProduct>();
    }
    
    public List<IProductBase> execute(){
        return new List<IProductBase>();
    }
}