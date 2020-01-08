public class Geocode {
  private static final String key = System.Label.GEOCodeAPIKey;// 'AIzaSyC-IVhA6vv3V4evHIdpFVF9u3mXOL0eYmk';

  public List<Results> results;

  public class Results {
    public Geometry geometry;
  }

  public class Geometry {
    public Location location;
  }

  public class Location {
    public Double lat, lng;
  }

  public static Geocode Parse(String json) {
    return (Geocode)System.JSON.deserialize(json, Geocode.class);
  }

  
  public static HttpResponse MakeGetCallout(String address, string countrycode) {
    Http http = new Http();

    HttpRequest request = new HttpRequest();
    system.debug('MY URL = ' + 'https://maps.googleapis.com/maps/api/geocode/json?address=' + EncodingUtil.urlEncode(address, 'UTF-8') + '&components=country:' + countrycode + '&key=' + key);
    request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address=' + EncodingUtil.urlEncode(address, 'UTF-8') + '&components=country:' + countrycode + '&key=' + key);
    request.setMethod('GET');

    HttpResponse response = http.send(request);

    return response;
  }
  
}