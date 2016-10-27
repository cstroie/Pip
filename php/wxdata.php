<?php
if (empty($_GET["id"])) {
  header("HTTP/1.0 404 Not Found");
  header("Content-Type: text/plain;charset=ASCII");
  echo "Invalid location provided. See https://weather.codes/";
} else {
  header("Content-Type: text/plain;charset=ASCII");
  if (empty($_GET["u"])) {
    $unit = "m";
  } else {
    $unit = $_GET["u"];
  };
  $url = "http://wxdata.weather.com/wxdata/weather/local/" . $_GET["id"] . "?cc=*&unit=" . $unit . "&dayf=2";
  $xml = simplexml_load_file($url);
  //var_dump($xml);
  if (empty($xml->dayf->day[0]->part[0]->t)) {
    $tc = $xml->dayf->day[0]->part[1]->t;
    $dn = "TN";
  } else {
    $tc = $xml->dayf->day[0]->part[0]->t;
    $dn = "TD";
  };
  $ut = $xml->head->ut;
  $dg = chr(223);
  echo "NW" . "\t" . $xml->cc->tmp . $dg . $ut . " (" . $xml->cc->flik . $dg . $ut . ")\t" . $xml->cc->t . "\r\n";
  echo $dn . "\t" . $xml->dayf->day[0]->low . "/" . $xml->dayf->day[0]->hi . $dg . $ut . "\t" . $tc . "\r\n";
  echo "TM" . "\t" . $xml->dayf->day[1]->low . "/" . $xml->dayf->day[1]->hi . $dg . $ut . "\t" . $xml->dayf->day[1]->part[0]->t . "\r\n";
  echo "BR" . "\t" . $xml->cc->bar->r . $xml->head->up . "\t" . (empty($xml->cc->bar->d) ? "steady" : $xml->cc->bar->d) . "\r\n";
  echo "SN" . "\t" . $xml->loc->sunr . "\t" . $xml->loc->suns . "\r\n";
};
// vim: set ft=php ai ts=2 sts=2 et sw=2 sta nowrap nu :
?>
