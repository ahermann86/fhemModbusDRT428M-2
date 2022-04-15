# fhemModbusDRT428M-2

#### FHEM Module zur Anbindung eines DRT428M-2 Modbus 3~ Energiemessgerät

<p align="center">
  <img src=pic/DRT428M-2.jpg width="600"/>
</p>

Grundsätzlich kann der Zähler per RS485 Adapter an einen Server angeschlossen werden wie z.B. https://github.com/ahermann86/fhemModbusSDM72DM

#### HowTo Beispiel:

1. Datei in FHEM hinein kopieren und laden. Wie z.B. https://wiki.fhem.de/wiki/Rotex_HPSU_Compact#Dateien
2. In FHEM Modbus Schnittstelle definieren. 
- `define ModBusLine Modbus /dev/ttyUSB2@38400,8,N,2`
3. In FHEM Modbus Zähler Device mit dem Modul definieren:
- `define DRT_Wohnung ModbusSDM72DM 1 5`
- `attr DRT_Wohnung IODev ModBusLine`
- `attr DRT_Wohnung event-on-change-reading Energy_total__kWh.*:0.5,Power_Sum__W:5,.*`

##### Modul Raw definition:
```
defmod DRT_Wohnung ModbusSDM72DM 1 5
attr DRT_Wohnung event-on-change-reading uRVerbrauch:0.05,.*
attr DRT_Wohnung room Haus
attr DRT_Wohnung stateFormat Verbrauch Total_Active_Power TVerbrauch uRTVerbrauch
attr DRT_Wohnung userReadings uRVerbrauch:Total_Active_Power.* \
{sprintf("%.03f %.03f %.03f %.03f", \
  ReadingsNum($name, "Total_Active_Power", 0),\
  ReadingsNum($name, "L1_Active_Power", 0),\
  ReadingsNum($name, "L2_Active_Power", 0),\
  ReadingsNum($name, "L3_Active_Power", 0))},\
uRTVerbrauch {sprintf("%.03f kWh", (split(" ", ReadingsVal($name, "Stat.Forward_Active_Energy", 0)))[3])}
```
<p align="center">
  <img src=pic/Modul.png/>
</p>

#### Aufzeichnung

##### Loggen:
```
define Log_Energie FileLog ./log/Energie-%Y-%m.log DRT_Wohnung:uRVerbrauch:.*|DRT_Wohnung:Stat.Forward_Active_Energy:.*
```
##### Plotten Gesamtverbrauch - Raw definition:
```
defmod SVG_Log_Energie_1 SVG Log_Energie:SVG_Log_Energie_1:CURRENT
attr SVG_Log_Energie_1 plotsize 1150,250
attr SVG_Log_Energie_1 room Haus
```

##### GPlot Datei:
```
# Created by FHEM/98_SVG.pm, 2022-04-10 23:15:29
set terminal png transparent size <SIZE> crop
set output '<OUT>.png'
set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"
set xlabel " "
set title '<TL>'
set ytics 
set y2tics 
set grid ytics
set ylabel "kW"
set y2label "kw"
set yrange [0:5]
set y2range [0:1]

#Log_Energie 4:DRT_Wohnung.uRVerbrauch\x3a::

plot "<IN>" using 1:2 axes x1y1 title 'Verbrauch' ls l0 lw 1 with steps
```

<p align="center">
  <img src=pic/Plot_Verbrauch.png/>
</p>

##### Plotten Einzelphasen - Raw definition:
```
defmod SVG_Log_Energie_2 SVG Log_Energie:SVG_Log_Energie_2:CURRENT
attr SVG_Log_Energie_2 plotsize 1150,250
attr SVG_Log_Energie_2 room Haus
```

GPlot Datei:
```
# Created by FHEM/98_SVG.pm, 2022-04-10 23:20:24
set terminal png transparent size <SIZE> crop
set output '<OUT>.png'
set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"
set xlabel " "
set title '<TL>'
set ytics 
set y2tics 
set grid ytics
set ylabel "kW"
set y2label "kW"
set yrange [0:1]
set y2range [0:1]

#Log_Energie 5:DRT_Wohnung.uRVerbrauch\x3a::
#Log_Energie 6:DRT_Wohnung.uRVerbrauch\x3a::
#Log_Energie 7:DRT_Wohnung.uRVerbrauch\x3a::

plot "<IN>" using 1:2 axes x1y1 title 'Verbrauch L1' ls l4 lw 1 with steps,\
     "<IN>" using 1:2 axes x1y1 title 'Verbrauch L2' ls l5 lw 1 with steps,\
     "<IN>" using 1:2 axes x1y1 title 'Verbrauch L3' ls l7 lw 1 with steps
```

<p align="center">
  <img src=pic/Plot_Einzelphasen.png/>
</p>

#### Statistik

##### Statistikmodul - Raw definition:
```
defmod StatDRT_Wohnung statistics DRT_Wohnung Stat.
attr StatDRT_Wohnung dayChangeTime 00:00:00
attr StatDRT_Wohnung deltaReadings Forward_Active_Energy
attr StatDRT_Wohnung group Statistik
attr StatDRT_Wohnung room SysHelper
attr StatDRT_Wohnung singularReadings DRT_Wohnung:Forward_Active_Energy:(Day|Month|Year)
```

##### Plotten Statistik - Raw definition:
```
defmod SVG_Log_Energie_3 SVG Log_Energie:SVG_Log_Energie_3:CURRENT
attr SVG_Log_Energie_3 plotsize 1150,250
attr SVG_Log_Energie_3 room Haus
```

GPlot Datei:
```
# Created by FHEM/98_SVG.pm, 2022-04-10 23:46:37
set terminal png transparent size <SIZE> crop
set output '<OUT>.png'
set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"
set xlabel " "
set title '<TL>'
set ytics 
set y2tics 
set grid
set ylabel "Verbrauch"
set y2label "Verbrauch"
set yrange [0:20]
set y2range [0:20]

#Log_Energie 5:DRT_Wohnung.Stat.Forward_Active_Energy\x3a::
#Log_Energie 7:DRT_Wohnung.Stat.Forward_Active_Energy\x3a::

plot "<IN>" using 1:2 axes x1y1 title 'Stunde' ls l3 lw 1 with steps,\
     "<IN>" using 1:2 axes x1y1 title 'Tag' ls l0fill lw 1 with steps
```

<p align="center">
  <img src=pic/Statistik.png/>
</p>
