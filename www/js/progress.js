// $Id: progress.js,v 1.20 2010/06/01 15:36:07 chabannf Exp $

// 
// CONTACT     : zonecheck@nic.fr
// AUTHOR      : Stephane D'Alu <sdalu@nic.fr>
//
// CREATED     : 2002/10/02 13:58:17
// REVISION    : $Revision: 1.20 $ 
// DATE        : $Date: 2010/06/01 15:36:07 $
//
// CONTRIBUTORS: (see also CREDITS file)
//
//
// LICENSE     : GPL v3 (or MIT/X11-like after agreement)
// COPYRIGHT   : AFNIC (c) 2003
//
// This file is part of ZoneCheck.
//
// ZoneCheck is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
// 
// ZoneCheck is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ZoneCheck; if not, write to the Free Software Foundation,
// Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//

/**
 * convert a time in sec into a string
 *  possible formats are 'mm:ss', 'hh:mm:ss' or '--:--'
 */
function zc_sec_to_timestr(sec) {
  if (sec < 0)
    return "--:--";

  hrs = Math.floor(sec / 3600); sec %= 3600;
  min = Math.floor(sec / 60);   sec %= 60;
  
  if (sec < 10)
    sec = "0" + sec;
   
  if (hrs > 0) {
    if (min < 10)
      min = "0" + min;
    return hrs + ":" + min + ":" + sec;
  } else {
    return min + ":" + sec;
  }
}

/**
 * convert a speed into a string (2 digits after the coma)
 */
function zc_speed_tostr(speed) {
  if (speed < 0)
    return "--.--";

  speed = speed * 100;
  cnt = Math.floor(speed) % 100;
  if (cnt < 10)
    cnt = "0" + cnt;
  unt = Math.floor(speed / 100);

  return unt + "." + cnt;
}

/**
 * switch off elements
 */
function zc_element_off(id) {
  document.getElementById(id).style.display = "none";
}

/**
 * remove id (so that it can be reused)
 */
function zc_element_clear_id(id) {
  document.getElementById(id).id = "";
}

/*======================================================================*/

/**
 * initialize locale for the progress bar (ie: internationalisation)
 */
function zc_pgr_setlocale(tprogress, progress, test, speed, time, na) {
  zc_pgr_l_title_progress = tprogress;
  zc_pgr_l_progress       = progress;
  zc_pgr_l_test           = test;
  zc_pgr_l_speed          = speed;
  zc_pgr_l_time           = time;
  zc_pgr_l_na             = na;
}

/**
 * quiet mode (no titles)
 */
function zc_pgr_setquiet(quiet) {
  zc_pgr_quiet = quiet;
}

/**
 * start progress bar
 */
function zc_pgr_start(count) {
  zc_pgr_starttime      = (new Date()).getTime();
  zc_pgr_processed      = 0;
  zc_pgr_last_processed = -1;
  zc_pgr_ticks          = 0;
  zc_pgr_totaltime      = 0;
  zc_pgr_totalsize      = count;
  zc_pgr_barsize        = 300;
  zc_pgr_tickersize	= 40;

  s  = "";
  if (! zc_pgr_quiet) {
    s += "<H2  id=\"zc-pgr-title\">" + zc_pgr_l_title_progress + "</H2>";
  }

  s += "<DIV id=\"zc-pgr-pbar\">";
  s += "<TABLE id=\"zc-pgr-pbar-out\"><TR><TD>";
  s += "<TABLE id=\"zc-pgr-pbar-in\" style='border-collapse: collapse;'>";
  // titles
  s += "<TR>";
  s += "<TD colspan=4>" + zc_pgr_l_progress + "</TD>";
  s += "<TD style='width: 2em;'></TD>"
  s += "<TD style='text-align: center;'>&nbsp;&nbsp;" + zc_pgr_l_test  + "&nbsp;&nbsp;</TD>";
  s += "<TD style='text-align: center;'>&nbsp;&nbsp;" + zc_pgr_l_speed + "&nbsp;&nbsp;</TD>";
  s += "<TD style='text-align: center;'>&nbsp;&nbsp;" + zc_pgr_l_time  + "&nbsp;&nbsp;</TD>";
  s += "</TR>";
  // progress bar information
  s += "<TR>";
  s += "<TD id=\"zc-pgr-pct\"   style='text-align: right; width: 4em'></TD>";
  if (zc_pgr_totalsize <= 0) {
    // infinit
    s += "<TD id=\"zc-pgr-pct0\"  style='border-style: solid none solid solid;'></TD>";
    s += "<TD id=\"zc-pgr-pct1\"  style='border-style: solid none; width: " + zc_pgr_tickersize + "px'></TD>";
    s += "<TD id=\"zc-pgr-pct2\"  style='border-style: solid solid solid none;'></TD>";
  } else {
    // limited
    s += "<TD id=\"zc-pgr-pct0\"  style='width: 0px'></TD>";
    s += "<TD id=\"zc-pgr-pct1\"  style='border-style: solid none solid solid;'></TD>";
    s += "<TD id=\"zc-pgr-pct2\"  style='border-style: solid solid solid none;'></TD>";
  }
  s += "<TD></TD>";
  s += "<TD id=\"zc-pgr-proc\"  style='text-align: center;'></TD>";
  s += "<TD id=\"zc-pgr-speed\" style='text-align: center;'></TD>";
  s += "<TD id=\"zc-pgr-eta\"   style='text-align: center;'></TD>";
  s += "</TR>";
  // spacer
  s += "<TR><TD colspan=8>&nbsp;</TD></TR>";
  // check description
  s += "<TR><TD id=\"zc-pgr-desc\" colspan=8></TD></TR>";
  s += "</TABLE>";
  s += "</TD><TR></TABLE>";
  s += "</DIV>";
  document.write(s);

  zc_pgr_setdesc("...");
  zc_pgr_update();

  // fire updater 2 times per second
  zc_pgr_timeoutid = setInterval("zc_pgr_updater()", 500);
}


/**
 * update the progress bar
 */
function zc_pgr_update() {
  // speed
  speed = zc_pgr_totaltime ? (1000*zc_pgr_processed/zc_pgr_totaltime) : -1.0;

  if (zc_pgr_totalsize > 0) {
    // percent done
    pct = Math.ceil(100 * zc_pgr_processed / zc_pgr_totalsize);

    // compute spent time
    nowtime   = (new Date()).getTime();
    zc_pgr_totaltime = nowtime - zc_pgr_starttime;

    // estimated time
    eta   = speed < 0 ? -1.0 : Math.ceil((zc_pgr_totalsize - zc_pgr_processed) / speed);

    //
    pctsize = zc_pgr_barsize * pct / 100;
    document.getElementById("zc-pgr-pct"  ).innerHTML = pct + "%&nbsp;";
    document.getElementById("zc-pgr-pct1" ).style.width = pctsize;
    document.getElementById("zc-pgr-pct2" ).style.width = zc_pgr_barsize-pctsize;
    document.getElementById("zc-pgr-eta"  ).innerHTML = zc_sec_to_timestr(eta);
  } else {
    pos0 = (2 * zc_pgr_ticks) % (zc_pgr_barsize * 2 - zc_pgr_tickersize);
    pos2 = zc_pgr_barsize-zc_pgr_tickersize - pos0;
    document.getElementById("zc-pgr-pct0" ).style.width = pos0;
    document.getElementById("zc-pgr-pct2" ).style.width = pos2;
    document.getElementById("zc-pgr-eta"  ).innerHTML = zc_pgr_l_na;
  }

  document.getElementById("zc-pgr-proc" ).innerHTML = zc_pgr_processed;
  document.getElementById("zc-pgr-speed").innerHTML = zc_speed_tostr(speed);
}


/**
 *
 */
function zc_pgr_setdesc(desc) {
  document.getElementById("zc-pgr-desc" ).innerHTML = desc;
}


/**
 *
 */
function zc_pgr_updater() {
  // don't tick if nothing has changed
  if (zc_pgr_processed != zc_pgr_last_processed) {
    zc_pgr_ticks += 1;
    zc_pgr_last_processed = zc_pgr_processed;
  }

  // update
  zc_pgr_update();
}


/**
 * process element in progress bar
 */
function zc_pgr_process(desc) {
  zc_pgr_processed += 1;   // one more
  zc_pgr_setdesc(desc);    // set description
}



/**
 * finish progress bar
 */
function zc_pgr_finish() {
  // remove timeout handler for updater
  clearTimeout(zc_pgr_timeoutid);

  // remove progress bar
  if (! zc_pgr_quiet) {
    zc_element_off("zc-pgr-title");
    zc_element_clear_id("zc-pgr-title"   );
  }
  zc_element_off("zc-pgr-pbar" );
  zc_element_clear_id("zc-pgr-pbar"    );
  zc_element_clear_id("zc-pgr-pbar-out");
  zc_element_clear_id("zc-pgr-pbar-in" );
  zc_element_clear_id("zc-pgr-pct"     );
  zc_element_clear_id("zc-pgr-pct0"    );
  zc_element_clear_id("zc-pgr-pct1"    );
  zc_element_clear_id("zc-pgr-pct2"    );
  zc_element_clear_id("zc-pgr-proc"    );
  zc_element_clear_id("zc-pgr-speed"   );
  zc_element_clear_id("zc-pgr-eta"     );
  zc_element_clear_id("zc-pgr-desc"    );
}
