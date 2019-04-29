people[1:5] <- c("GAGELER", "NETTLE","EDELMAN", "KENNETT", "MERKEL")
outcome[1:5] <- c("Chief Judge","Judge","Judge", "Respondent","Appellant")
case[1:5] <- "Nauru_a"

people[6:10] <- list("GAGELER", "NETTLE","EDELMAN", "KENNETT", "GILBERT")
outcome[6:10] <- "unanimously allowed"
case[6:10] <- "Nauru_b"

people[11:17] <-c("BELL", "GAGELER", "KEANE", "GORDON", "EDELMAN", "JORDAN","ABRAHAM") 
outcome[11:17] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[11:17] <- "McKell"


people[18:24] <-c("BELL", "KEANE", "NETTLE", "GORDON", "EDELMAN", "VANDONGEN","FORRESTER") 
outcome[18:24] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[18:24] <- "OKS"

people[25:31] <-c("KIEFEL", "BELL","KEANE", "GORDON", "EDELMAN", "WILLIAMS","GLEESON") 
outcome[25:31] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[25:31] <- "Parkes"


people[32:38] <-c("KIEFEL", "GAGELER","NETTLE", "GORDON", "EDELMAN", "WALKER","HUTLEY") 
outcome[32:38] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[32:38] <- "Rinehart_a"

people[39:45] <-c("KIEFEL", "GAGELER","NETTLE", "GORDON", "EDELMAN", "NG","HUTLEY") 
outcome[39:45] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[39:45] <- "Rinehart_b"

people <- unlist(people)
portfolio <- tibble(people, role, case)