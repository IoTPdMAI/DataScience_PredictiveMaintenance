# Fasse f�nf Sekunden Bereiche zusammen

library(lubridate)

dinmerge_round <- dinmerge
dinmerge_round$DateTime <- round_date(dinmerge$DateTime, "5 secs")

# Versuch: Aggregieren der Reihen mit selbem Zeitstempel
#aggregate(dinmerge_round, dinmerge_round$DateTime, mean)

# L�schen der Zeitstempel-Duplikate 
# dinmerge_round_wod = dinmerge_round[!duplicated(dinmerge_round$DateTime),]

# Analyse der Reihen
str(dinmerge_round)
duplicated(dinmerge_round$DateTime)


# Zusammenfassen der Reihen

library(plyr)
dinmerge_round$DateTime<-as.POSIXct(dinmerge_round$DateTime)


dinmerge_round_sum <- ddply(dinmerge_round, c("DateTime"), summarise,
                Dieself�llstand    = mean(Dieself�llstand, na.rm = TRUE),
                Frischwassertank    = mean(Frischwassertank, na.rm = TRUE),
               `Drehzahl M1`   = mean(`Drehzahl M1`, na.rm = TRUE),
               `K�hlmitteltemp M1`    = mean(`K�hlmitteltemp M1`, na.rm = TRUE),
               `�ldruck M1`    = mean(`�ldruck M1`, na.rm = TRUE),
               `Drehzahl M2`    = mean(`Drehzahl M2`, na.rm = TRUE),
               `K�hlmitteltemp M2`    = mean(`K�hlmitteltemp M2`, na.rm = TRUE),
               `�ldruck M2`    = mean(`�ldruck M2`, na.rm = TRUE),
               `Betriebsstund. M1`    = mean(`Betriebsstund. M1`, na.rm = TRUE),
               `Betriebsstund. M2`    = mean(`Betriebsstund. M2`, na.rm = TRUE),
               `Betriebsstund. Kran1`    = mean(`Betriebsstund. Kran1`, na.rm = TRUE),
               `Betriebsstund. Kran2`    = mean(`Betriebsstund. Kran2`, na.rm = TRUE),
               `Betriebsstund. Kran3`    = mean(`Betriebsstund. Kran3`, na.rm = TRUE),
               `Hydraulik�ltank F�llstand`    = mean(`Hydraulik�ltank F�llstand`, na.rm = TRUE),
               `Hydraulik�l Temp`    = mean(`Hydraulik�l Temp`, na.rm = TRUE),
               `Getr. Arbeits. Fahrdruck A`    = mean(`Getr. Arbeits. Fahrdruck A`, na.rm = TRUE),
               `Getr. Arbeits. Fahrdruck B`    = mean(`Getr. Arbeits. Fahrdruck B`, na.rm = TRUE),
               `Getr. Arbeits. Speisedruck`    = mean(`Getr. Arbeits. Speisedruck`, na.rm = TRUE),
               `Partikelf. Regenerationh`    = mean(`Partikelf. Regenerationh`, na.rm = TRUE),
               `Partikelf. Filterwiderstand`    = mean(`Partikelf. Filterwiderstand`, na.rm = TRUE),
               `Partikelf. Regenerations`    = mean(`Partikelf. Regenerations`, na.rm = TRUE),
               `Getr. �berst. �ltemp. 1`    = mean(`Getr. �berst. �ltemp. 1`, na.rm = TRUE),
               `Getr. �berst. �ltemp. 2`    = mean(`Getr. �berst. �ltemp. 2`, na.rm = TRUE),
               `Getr. �berst. Retarder1`    = mean(`Getr. �berst. Retarder1`, na.rm = TRUE),
               `Getr. �berst. Retarder2`    = mean(`Getr. �berst. Retarder2`, na.rm = TRUE),
               `Getr. �berst. Fahrdruck A`    = mean(`Getr. �berst. Fahrdruck A`, na.rm = TRUE),
               `Getr. �berst. Fahrdruck B`    = mean(`Getr. �berst. Fahrdruck B`, na.rm = TRUE),
               `Getr. �berst. Speisedruck`    = mean(`Getr. �berst. Speisedruck`, na.rm = TRUE)
)

sum(is.na(dinmerge))
sum(is.na(dinmerge_round_sum))


### Zusammenfassen, Zeitbereich: 1 Minute ###

dinmerge_round1m <- dinmerge
dinmerge_round1m$DateTime <- round_date(dinmerge$DateTime, "minute")

dinmerge_round1m$DateTime<-as.POSIXct(dinmerge_round1m$DateTime)


dinmerge_round1m_sum <- ddply(dinmerge_round1m, c("DateTime"), summarise,
                            Dieself�llstand    = mean(Dieself�llstand, na.rm = TRUE),
                            Frischwassertank    = mean(Frischwassertank, na.rm = TRUE),
                            `Drehzahl M1`   = mean(`Drehzahl M1`, na.rm = TRUE),
                            `K�hlmitteltemp M1`    = mean(`K�hlmitteltemp M1`, na.rm = TRUE),
                            `�ldruck M1`    = mean(`�ldruck M1`, na.rm = TRUE),
                            `Drehzahl M2`    = mean(`Drehzahl M2`, na.rm = TRUE),
                            `K�hlmitteltemp M2`    = mean(`K�hlmitteltemp M2`, na.rm = TRUE),
                            `�ldruck M2`    = mean(`�ldruck M2`, na.rm = TRUE),
                            `Betriebsstund. M1`    = mean(`Betriebsstund. M1`, na.rm = TRUE),
                            `Betriebsstund. M2`    = mean(`Betriebsstund. M2`, na.rm = TRUE),
                            `Betriebsstund. Kran1`    = mean(`Betriebsstund. Kran1`, na.rm = TRUE),
                            `Betriebsstund. Kran2`    = mean(`Betriebsstund. Kran2`, na.rm = TRUE),
                            `Betriebsstund. Kran3`    = mean(`Betriebsstund. Kran3`, na.rm = TRUE),
                            `Hydraulik�ltank F�llstand`    = mean(`Hydraulik�ltank F�llstand`, na.rm = TRUE),
                            `Hydraulik�l Temp`    = mean(`Hydraulik�l Temp`, na.rm = TRUE),
                            `Getr. Arbeits. Fahrdruck A`    = mean(`Getr. Arbeits. Fahrdruck A`, na.rm = TRUE),
                            `Getr. Arbeits. Fahrdruck B`    = mean(`Getr. Arbeits. Fahrdruck B`, na.rm = TRUE),
                            `Getr. Arbeits. Speisedruck`    = mean(`Getr. Arbeits. Speisedruck`, na.rm = TRUE),
                            `Partikelf. Regenerationh`    = mean(`Partikelf. Regenerationh`, na.rm = TRUE),
                            `Partikelf. Filterwiderstand`    = mean(`Partikelf. Filterwiderstand`, na.rm = TRUE),
                            `Partikelf. Regenerations`    = mean(`Partikelf. Regenerations`, na.rm = TRUE),
                            `Getr. �berst. �ltemp. 1`    = mean(`Getr. �berst. �ltemp. 1`, na.rm = TRUE),
                            `Getr. �berst. �ltemp. 2`    = mean(`Getr. �berst. �ltemp. 2`, na.rm = TRUE),
                            `Getr. �berst. Retarder1`    = mean(`Getr. �berst. Retarder1`, na.rm = TRUE),
                            `Getr. �berst. Retarder2`    = mean(`Getr. �berst. Retarder2`, na.rm = TRUE),
                            `Getr. �berst. Fahrdruck A`    = mean(`Getr. �berst. Fahrdruck A`, na.rm = TRUE),
                            `Getr. �berst. Fahrdruck B`    = mean(`Getr. �berst. Fahrdruck B`, na.rm = TRUE),
                            `Getr. �berst. Speisedruck`    = mean(`Getr. �berst. Speisedruck`, na.rm = TRUE)
)

sum(is.na(dinmerge_round1m_sum))



### Zusammenfassen, Zeitbereich: 5 Minuten ###

dinmerge_round5m <- dinmerge
dinmerge_round5m$DateTime <- round_date(dinmerge$DateTime, "5 minutes")

dinmerge_round5m$DateTime<-as.POSIXct(dinmerge_round5m$DateTime)


dinmerge_round5m_sum <- ddply(dinmerge_round5m, c("DateTime"), summarise,
                              Dieself�llstand    = mean(Dieself�llstand, na.rm = TRUE),
                              Frischwassertank    = mean(Frischwassertank, na.rm = TRUE),
                              `Drehzahl M1`   = mean(`Drehzahl M1`, na.rm = TRUE),
                              `K�hlmitteltemp M1`    = mean(`K�hlmitteltemp M1`, na.rm = TRUE),
                              `�ldruck M1`    = mean(`�ldruck M1`, na.rm = TRUE),
                              `Drehzahl M2`    = mean(`Drehzahl M2`, na.rm = TRUE),
                              `K�hlmitteltemp M2`    = mean(`K�hlmitteltemp M2`, na.rm = TRUE),
                              `�ldruck M2`    = mean(`�ldruck M2`, na.rm = TRUE),
                              `Betriebsstund. M1`    = mean(`Betriebsstund. M1`, na.rm = TRUE),
                              `Betriebsstund. M2`    = mean(`Betriebsstund. M2`, na.rm = TRUE),
                              `Betriebsstund. Kran1`    = mean(`Betriebsstund. Kran1`, na.rm = TRUE),
                              `Betriebsstund. Kran2`    = mean(`Betriebsstund. Kran2`, na.rm = TRUE),
                              `Betriebsstund. Kran3`    = mean(`Betriebsstund. Kran3`, na.rm = TRUE),
                              `Hydraulik�ltank F�llstand`    = mean(`Hydraulik�ltank F�llstand`, na.rm = TRUE),
                              `Hydraulik�l Temp`    = mean(`Hydraulik�l Temp`, na.rm = TRUE),
                              `Getr. Arbeits. Fahrdruck A`    = mean(`Getr. Arbeits. Fahrdruck A`, na.rm = TRUE),
                              `Getr. Arbeits. Fahrdruck B`    = mean(`Getr. Arbeits. Fahrdruck B`, na.rm = TRUE),
                              `Getr. Arbeits. Speisedruck`    = mean(`Getr. Arbeits. Speisedruck`, na.rm = TRUE),
                              `Partikelf. Regenerationh`    = mean(`Partikelf. Regenerationh`, na.rm = TRUE),
                              `Partikelf. Filterwiderstand`    = mean(`Partikelf. Filterwiderstand`, na.rm = TRUE),
                              `Partikelf. Regenerations`    = mean(`Partikelf. Regenerations`, na.rm = TRUE),
                              `Getr. �berst. �ltemp. 1`    = mean(`Getr. �berst. �ltemp. 1`, na.rm = TRUE),
                              `Getr. �berst. �ltemp. 2`    = mean(`Getr. �berst. �ltemp. 2`, na.rm = TRUE),
                              `Getr. �berst. Retarder1`    = mean(`Getr. �berst. Retarder1`, na.rm = TRUE),
                              `Getr. �berst. Retarder2`    = mean(`Getr. �berst. Retarder2`, na.rm = TRUE),
                              `Getr. �berst. Fahrdruck A`    = mean(`Getr. �berst. Fahrdruck A`, na.rm = TRUE),
                              `Getr. �berst. Fahrdruck B`    = mean(`Getr. �berst. Fahrdruck B`, na.rm = TRUE),
                              `Getr. �berst. Speisedruck`    = mean(`Getr. �berst. Speisedruck`, na.rm = TRUE)
)

sum(is.na(dinmerge_round5m_sum))

