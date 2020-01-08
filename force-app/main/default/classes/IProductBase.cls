public interface IProductBase {
    
	// Whether this product should be
	//   interpreted as being a "primary" product when evaluated together in a List<IProductBase>
	Boolean getIsPrimary();

	String getId();

	String getName();

	String getDescription();
    
  String getMembershipType();

	Decimal getPrice();

	Id getRelatedRecordId();
	
	void setRelatedRecordId(Id recordId);

	void setPrice(Decimal price);

	void setName(String name);

	void setDescription(String description);
    
  void setMembershipType(String membershipType);

	Id save();
}