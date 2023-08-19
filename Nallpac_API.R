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


retrieve_product_list<-function(ids,user, pw,search_type = 'upc'){
  final_df<-data.frame()
  missing_df<-data.frame(id=NA)
  response<-list()
  counter<-0
  for(id in ids){
    counter = counter+1
    print(counter)
    if(search_type == 'upc') response[[counter]]<-retrieve_UPC_info(as.integer(id),user,pw)
    if(search_type == 'sku') response[[counter]]<-retrieve_SKU_info(as.integer(id),user,pw)
    if(counter %% 100 == 0) saveRDS(response, 'response.RDS')
  }
  print('parsing...')
  saveRDS(response, 'response.RDS')
  for(l in 1:length(response)){
    response2<-response[[l]]
    print(l)
    if(response2$status_code == 200){
      raised <- content(response2, as="text")
      parsed<- fromJSON(raised)
      df<-data.frame(0)
      for(i in 1:length(parsed)){
        #print(i)
        if(class(parsed[[i]]) == 'data.frame'){
          tempdf<-parsed[[i]]
          tempdf2<-data.frame()
          for(j in 1:ncol(tempdf)){
            tempdf2[1,j]<-paste(tempdf[,j], sep='; ',collapse = '; ')
          }
          names(tempdf2)<-paste0(names(parsed)[[i]],'_',names(tempdf))
          df<-cbind(df,tempdf2)
        } else {
          tempdf<-data.frame(attribute = 'value')
          if(is.null(parsed[[i]])) parsed[[i]]<-''
          tempdf[1,1]<-parsed[[i]]
          names(tempdf)<-names(parsed)[[i]]
          df<-cbind(df,tempdf)
        }
      }
      final_df<-bind_rows(final_df,df[2:ncol(df)])
    }
    else{
      missing_df[nrow(missing_df)+1,'id']<-id
    }
  }
  
  return(list(final_df,missing_df))
}

#input
product_list<-openxlsx::read.xlsx('products.xlsx')
skus<-na.omit(product_list$SKUs)
upcs<-as.numeric(na.omit(product_list$UPCs))
