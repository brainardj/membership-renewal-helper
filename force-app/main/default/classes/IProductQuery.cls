public interface IProductQuery {
    
    void setParameters(Map<String,String> params);
    
    List<IProductBase> getProducts();
    
    List<IProductBase> execute();
    
    
}