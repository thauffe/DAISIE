DAISIE_format_IW = function(island_replicates,time,M,sample_freq)
{
  several_islands = list()
  for(rep in 1:length(island_replicates)) 
  {
    the_island = island_replicates[[rep]]
    
    stt_all = matrix(ncol = 4,nrow = sample_freq + 1)
    colnames(stt_all) = c("Time","nI","nA","nC")
    stt_all[,"Time"] = rev(seq(from = 0,to = time,length.out = sample_freq + 1))
    stt_all[1,2:4] = c(0,0,0) 
    
    the_stt = the_island$stt_table
    
    for(i in 2:nrow(stt_all))
    { 
      the_age = stt_all[i,"Time"]	
      stt_all[i,2:4] = the_stt[max(which(the_stt[,"Time"] >= the_age)),2:4]
    }
    island_list = list()
    
    if(sum(the_stt[nrow(the_stt),2:4]) == 0)
    { 
      
      island_list[[1]] = list(island_age = time,not_present = M, stt_all = stt_all)

    } else
    {
      island_list[[1]] = list(island_age = time,not_present = M - length(the_island$taxon_list), 
                              stt_all = stt_all)
      
      for(y in 1:length(the_island$taxon_list))
      {
        island_list[[y+1]] = the_island$taxon_list[[y]]
      }    
    }
    
    island_list = Add_brt_table(island_list)
    
    several_islands[[rep]] = island_list
    
    print(paste("Island being formatted: ",rep,"/",length(island_replicates),sep = ""))
    
  }
  return(several_islands)  
}


Add_brt_table = function(island) {
  
  island_age <- island[[1]]$island_age
  
  
  if (length(island) == 1) {
    brts_table = matrix(ncol = 4, nrow = 1)
    brts_table[1, ] = c(island_age, 0, 0, NA)
    island[[1]]$brts_table<-brts_table
  }else{
    
    island_top = island[[1]]
    island[[1]] = NULL
    
    btimes <- list()
    for (i in 1:length(island)) 
      {
      btimes[[i]] = island[[i]]$branching_times[-1]
      }
   
    island = island[rev(order(sapply(btimes, "[", 1)))]
    
    il<-unlist(island)
    stac1s<-which(il[which(names(il)=='stac')]=='1')
    stac5s<-which(il[which(names(il)=='stac')]=='5')
    stac1_5s<-sort(c(stac1s,stac5s))
    
    if(length(stac1_5s)!=0) {
      
      if(length(stac1_5s)==length(island))
      {
        brts_table = matrix(ncol = 4, nrow = 1)
        brts_table[1, ] = c(island_age, 0, 0, NA) 
        island_no_stac1or5<-NULL
      }else{island_no_stac1or5<-island[-stac1_5s]}
    }
    
    if(length(stac1_5s)==0) {island_no_stac1or5<-island}
    
    if(length(island_no_stac1or5)!=0){
      btimes = list()
      for (i in 1:length(island_no_stac1or5)) {
        btimes[[i]] = island_no_stac1or5[[i]]$branching_times[-1]
      }
      brts = rev(sort(unlist(btimes)))
      brts_IWK = matrix(ncol = 4, nrow = length(brts))
      pos1 = 0
      for (i in 1:length(btimes)) {
        the_brts = btimes[[i]]
        the_stac = island_no_stac1or5[[i]]$stac
        pos2 = pos1 + length(the_brts)
        brts_IWK[(pos1 + 1):pos2, 1] = the_brts
        brts_IWK[(pos1 + 1):pos2, 2] = i
        brts_IWK[(pos1 + 1):pos2, 3] = seq(1, length(the_brts))
        brts_IWK[(pos1 + 1):pos2, 4] = (the_stac == 2) + 
          (the_stac == 3) + (the_stac == 4) * 0
        pos1 = pos2
      }
      brts_table = brts_IWK[rev(order(brts_IWK[, 1])), ]
      brts_table = rbind(c(island_age, 0, 0, NA), brts_table)
    }
    
    island_top$brts_table = brts_table
    
    if(length(stac1_5s)!=0){
      for(i in 1:length(stac1_5s)) {
        island[[length(island) + 1]] <- island[[stac1_5s[i]]]
        island[[stac1_5s[i]]] <- NULL
        stac1_5s = stac1_5s - 1
      }
    }
    island <- append(list(island_top), island)}
  
  colnames(island[[1]]$brts_table) = c("brt", "clade", "event", "endemic")
  return(island)
}