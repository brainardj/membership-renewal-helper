// Wrapper class to support dynamic distance sorting
public class IABCChapter extends FontevaProduct implements Comparable {


    private Decimal lat;
    
     
    private Decimal lng;
    
    
    public Boolean isSelect {get;set;}

    
    public Decimal distance {get;set;}

    
    public Boolean isStudentChapter {get;set;}

    
    private static final Integer DISTANCE_THRESHOLD = 50;
    
    
    
    
    public IABCChapter(){
        super();
    }
     
    public IABCChapter(String name, Decimal price){
        super(name,price);
    }
    
    public IABCChapter(OrderApi__Item__c chapterItm, Decimal myDistance, Boolean myselect, Boolean StudentChapter) {
        item = chapterItm;
        isSelect = myselect;
        isStudentChapter = StudentChapter;
        distance =  myDistance.setScale(2);
    }
    
    /**
     * @method getDistance
     * 
     * @description Finds the distance from an arbitrary location ("here")
     *   to the Chapter's location ("there")
     * 
     * @return Double Distance from here to there.
     */
    public Double getDistance(Integer lat, Integer lng){
    	Location here;
        Location there;
        Integer difference;
        
        there = Location.newInstance(this.lat,this.lng);
        here = Location.newInstance(lat,lng);
        
        return here.getDistance(there, 'km');
    }
    
    public System.Location getLocation(){
        return Location.newInstance(this.lat,this.lng);
    }
    
    public Boolean isNear(String conAddress){
		System.Location here;
        System.Location there;
        Decimal distance;
        
        here = toLocation(conAddress,'USA');
        there = this.getLocation();
        
        // Return the distance from here to there.
        return System.Location.getDistance(here, there, 'mi') < DISTANCE_THRESHOLD;
    }
    
    public static System.Location toLocation(String conAddress, String mailingCountryCode){
        //GEOCODE API callout to populate latitude and longitude on Contact
        HttpResponse res = Geocode.MakeGetCallout(conAddress, mailingCountryCode);
        
        Geocode GP = Geocode.parse(res.getBody());
        Decimal lat;
        Decimal lng;
        
        
        if( GP.results.size() > 0 ){
            lat = GP.results[0].Geometry.Location.lat;
            lng = GP.results[0].Geometry.Location.lng;
        } else {
            throw new GeoLocationException('No geocode results.');
        }
        
        return System.Location.newInstance(lat,lng);
    }


    public IABCChapter(OrderApi__Item__c chapter){
        super(chapter);
        this.lat = chapter.Chapter_Location__latitude__s;
		this.lng = chapter.Chapter_Location__longitude__s;
    }
    
    public Decimal getLat(){
        return this.lat;
    }
    
    public Decimal getLng(){
		return this.lng;
    }
    
    public IABCChapter(OrderApi__Item__c chapter, Decimal myDistance, Boolean myselect) {
        item = chapter;
        isSelect = myselect;
        isStudentChapter = FALSE;
        distance =  myDistance.setScale(2);
    } 
    
    public IABCChapter(OrderApi__Item__c chapter, Decimal myDistance) {
        item = chapter;
        isSelect = FALSE;
        isStudentChapter = FALSE;
        distance = myDistance.setScale(2);
    }
    
    public Integer compareTo(Object objToCompare) {
        return Integer.valueOf(distance -  ((IABCChapter)objToCompare).distance );
    }
    
    private class GeoLocationException extends Exception {}
}