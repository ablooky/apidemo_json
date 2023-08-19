# Loading packages
library(httr)
library(jsonlite)
library(openxlsx)
library(dplyr)

#Retrieve product Information from NALPAC website. 

#User authentication
user<-'abc@xyzemail.com'
pw<-'************************'


#Product Requests
#Get product by sku 
#https://api2.nalpac.com/Help/Api/GET-api-product-sku
#product = json_decode(CallAPI("GET", "https://api2.nalpac.com/api/product/10006"));
retrieve_SKU_info<-function(sku=1006, user,pw){
  final_url<-paste0('https://api2.nalpac.com/api/product/',sku)
  product_info<-httr::GET(url=final_url,accept_json(),authenticate(user, pw))
  return(product_info)
}



#Get product by upc 
#https://api2.nalpac.com/Help/Api/GET-api-product_upc
#product2 = json_decode(CallAPI("GET", "https://api2.nalpac.com/api/product?upc=782631003079"));
retrieve_UPC_info<-function(upc=782631003079, user,pw){
  final_url<-paste0('https://api2.nalpac.com/api/product?upc=',upc)
  product_info<-httr::GET(url=final_url,accept_json(),authenticate(user, pw))
  return(product_info)
}
