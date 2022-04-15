##############################################
# $Id: 98_ModbusDRT428M.pm 
#
# fhem Modul für Stromzähler DRT428M-2/-3 von Stromzähler.eu
# verwendet Modbus.pm als Basismodul für die eigentliche Implementation des Protokolls.
#
#  by A. Hermann
#
##############################################################################
# Changelog:
# 2022-04-08  initial release

package main;

use strict;
use warnings;

sub ModbusDRT428M_Initialize($);

# deviceInfo defines properties of the device.
# some values can be overwritten in parseInfo, some defaults can even be overwritten by the user with attributes if a corresponding attribute is added to AttrList in _Initialize.
#
my %DRT428MdeviceInfo = (
  "timing" => {
    timeout   =>  0.3,
    commDelay =>  0.05,  # min. delay between two communications 
    sendDelay =>  0.1,   # min. delay between two sends
    }, 
  "h" => {
    read    =>  3,
    write   =>  16,
    defLen    =>  2,
    combine   =>  25,   # combined read of up to x adjacent registers during getUpdate
    defUnpack =>  "f>",
    defShowGet  =>  1,
    defPoll =>  1,
    defSet => 0,
    },
);

my %DRT428MparseInfo = (
  "h14"  => { name => "L1 Voltage"                , reading => "L1_Voltage"                , format => '%.01f V' },
  "h16"  => { name => "L2 Voltage"                , reading => "L2_Voltage"                , format => '%.01f V' },
  "h18"  => { name => "L3 Voltage"                , reading => "L3_Voltage"                , format => '%.01f V' },
  "h22"  => { name => "L1 Current"                , reading => "L1_Current"                , format => '%.03f A' },
  "h24"  => { name => "L2 Current"                , reading => "L2_Current"                , format => '%.03f A' },
  "h26"  => { name => "L3 Current"                , reading => "L3_Current"                , format => '%.03f A' },
  "h28"  => { name => "Total Active Power"        , reading => "Total_Active_Power"        , format => '%.03f kW' },
  "h30"  => { name => "L1 Active Power"           , reading => "L1_Active_Power"           , format => '%.03f kW' },
  "h32"  => { name => "L2 Active Power"           , reading => "L2_Active_Power"           , format => '%.03f kW' },
  "h34"  => { name => "L3 Active Power"           , reading => "L3_Active_Power"           , format => '%.03f kW' },
 #"h36"  => { name => "Total reactive Power"      , reading => "Total_reactive_Power"      , format => '%.03f kVar' },
 #"h38"  => { name => "L1 reactive Power"         , reading => "L1_reactive_Power"         , format => '%.03f kVar' },
 #"h40"  => { name => "L2 reactive Power"         , reading => "L2_reactive_Power"         , format => '%.03f kVar' },
 #"h42"  => { name => "L3 reactive Power"         , reading => "L3_reactive_Power"         , format => '%.03f kVar' },
 #"h44"  => { name => "Total Apparent Power"      , reading => "Total_Apparent_Power"      , format => '%.03f kVA' },
 #"h46"  => { name => "L1 Apparent Power"         , reading => "L1_Apparent_Power"         , format => '%.03f kVA' },
 #"h48"  => { name => "L2 Apparent Power"         , reading => "L2_Apparent_Power"         , format => '%.03f kVA' },
 #"h50"  => { name => "L3 Apparent Power"         , reading => "L3_Apparent_Power"         , format => '%.03f kVA' },

  "h258" => { name => "L1 Total Active Energy"    , reading => "L1_Total_Active_Energy"    , format => '%.03f kWh' },
  "h260" => { name => "L2 Total Active Energy"    , reading => "L2_Total_Active_Energy"    , format => '%.03f kWh' },
  "h262" => { name => "L3 Total Active Energy"    , reading => "L3_Total_Active_Energy"    , format => '%.03f kWh' },
  "h264" => { name => "Forward Active Energy"     , reading => "Forward_Active_Energy"     , format => '%.03f kWh' },
  "h266" => { name => "L1 Forward Active Energy"  , reading => "L1_Forward_Active_Energy"  , format => '%.03f kWh' },
  "h268" => { name => "L2 Forward Active Energy"  , reading => "L2_Forward_Active_Energy"  , format => '%.03f kWh' },
  "h270" => { name => "L3 Forward Active Energy"  , reading => "L3_Forward_Active_Energy"  , format => '%.03f kWh' },
  "h272" => { name => "Reverse Active Energy"     , reading => "Reverse_Active_Energy"     , format => '%.03f kWh' },
  "h274" => { name => "L1 Reverse Active Energy"  , reading => "L1_Reverse_Active_Energy"  , format => '%.03f kWh' },
  "h276" => { name => "L2 Reverse Active Energy"  , reading => "L2_Reverse_Active_Energy"  , format => '%.03f kWh' },
  "h278" => { name => "L3 Reverse Active Energy"  , reading => "L3_Reverse_Active_Energy"  , format => '%.03f kWh' },
 #"h280" => { name => "Total Reactive Energy"     , reading => "Total_Reactive_Energy"     , format => '%.03f kVarh' },
 #"h282" => { name => "L1 Reactive Energy"        , reading => "L1_Reactive_Energy"        , format => '%.03f kVarh' },
 #"h284" => { name => "L2 Reactive Energy"        , reading => "L2_Reactive_Energy"        , format => '%.03f kVarh' },
 #"h286" => { name => "L3 Reactive Energy"        , reading => "L3_Reactive_Energy"        , format => '%.03f kVarh' },
 #"h288" => { name => "Forward Reactive Energy"   , reading => "Forward_Reactive_Energy"   , format => '%.03f kVarh' },
 #"h290" => { name => "L1 Forward Reactive Energy", reading => "L1_Forward_Reactive_Energy", format => '%.03f kVarh' },
 #"h292" => { name => "L2 Forward Reactive Energy", reading => "L2_Forward_Reactive_Energy", format => '%.f kVarh' },
 #"h294" => { name => "L3 Forward Reactive Energy", reading => "L3_Forward_Reactive_Energy", format => '%.f kVarh' },
 #"h296" => { name => "Reverse Reactive Energy"   , reading => "Reverse_Reactive_Energy"   , format => '%.f kVarh' },
 #"h298" => { name => "L1 Reverse Reactive Energy", reading => "L1_Reverse_Reactive_Energy", format => '%.f kVarh' },
 #"h300" => { name => "L2 Reverse Reactive Energy", reading => "L2_Reverse_Reactive_Energy", format => '%.f kVarh' },
 #"h302" => { name => "L3 Reverse Reactive Energy", reading => "L3_Reverse_Reactive_Energy", format => '%.f kVarh' },
);


#####################################
sub
ModbusDRT428M_Initialize($)
{
  my ($modHash) = @_;

  require "$attr{global}{modpath}/FHEM/98_Modbus.pm";

  $modHash->{parseInfo}  = \%DRT428MparseInfo;
  $modHash->{deviceInfo} = \%DRT428MdeviceInfo;

  ModbusLD_Initialize($modHash);

  $modHash->{AttrList} = $modHash->{AttrList} . " " .
    $modHash->{ObjAttrList} . " " .
    $modHash->{DevAttrList} . " " .
    "poll-.* " .
    "polldelay-.* ";
}


1;
