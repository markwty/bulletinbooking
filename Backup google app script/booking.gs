function onEdit(e){
  const rg = e.range;
  if (rg.getSheet().getName() === "Booking" || rg.getSheet().getName() === "Event Booking"){
    if (rg.isChecked()) {
      if (rg.getA1Notation() === "B4"){
        refresh();
        rg.uncheck();
      } else if (rg.getA1Notation() === "C4"){
        deleteEntry2();
        rg.uncheck();
      }
    } else if (rg.getA1Notation() === "E2"){
      storeAndApplyAttendance(parseInt(e.oldValue), parseInt(e.value));
    }
  }
}

function refresh() {
  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  var range = spreadsheet.getRange("A5:A5");
  var originalFormula = range.getCell(1, 1).getFormula();
  if(originalFormula){
    range.getCell(1, 1).setFormula('');
    SpreadsheetApp.flush();
    range.getCell(1, 1).setFormula(originalFormula);
  }
}

String.prototype.replaceAll = function(search, replacement) {
  var target = this;
  return target.replace(new RegExp(search, 'g'), replacement);
};

function deleteEntry() {
  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  var activeRange = spreadsheet.getActiveRange();
  var values = activeRange.getValues()[0];
  var range = spreadsheet.getRange("B1:E4");
  var date = Utilities.formatDate(range.getCell(2,4).getValue(), 'Etc/GMT-8', 'MM-dd-yyyy');
  if (values.length == 2) {
    var query = '"<insert url here>?date=' + date + "&time=" + values[0] + "&name=" + values[1] + '"';
    query = query.replaceAll(" ", "%20");
    range.getCell(3, 2).setFormula("IMPORTDATA(" + query + ")");
    SpreadsheetApp.flush();
    Utilities.sleep(1500);
    if (range.getCell(3, 2).getValue() == "Done deletion") {
      /*
      var Avals = spreadsheet.getRange("A1:A").getValues();
      var lastRow = Avals.filter(String).length + 4;
      var rowNum = activeRange.getCell(1,1).getRow();
      var lastRange = spreadsheet.getRange("A6"+":B"+lastRow);
      var colors = lastRange.getFontColors();
      */
      spreadsheet.deleteRow(rowNum);
      spreadsheet.insertRowAfter(55 - 1);
      spreadsheet.getRange("D4:D4").clearContent();
      refresh();
      /*
      Utilities.sleep(1500);
      colors.splice(rowNum-6,1);
      lastRange = spreadsheet.getRange("A6"+":B"+(lastRow-1));
      lastRange.setFontColors(colors);
      */
    }
  } else {
    spreadsheet.toast("Selected range should be 2 cells (time and name)");
  }
}

function deleteEntry2() {
  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  //var ui = SpreadsheetApp.getUi();
  //var result = ui.prompt("Please type row number to delete");
  var result = spreadsheet.getRange("D4:D4").getValues()[0];
  var activeRange = spreadsheet.getRange("A"+result+":B"+result);
  var values = activeRange.getValues()[0];
  var range = spreadsheet.getRange("B1:E4");
  var date = Utilities.formatDate(range.getCell(2,4).getValue(), 'Etc/GMT-8', 'MM-dd-yyyy');
  if (values.length == 2) {
    var query = '"<insert url here>?date=' + date + "&time=" + values[0] + "&name=" + values[1] + '"';
    query = query.replaceAll(" ", "%20");
    range.getCell(3, 2).setFormula("IMPORTDATA(" + query + ")");
    SpreadsheetApp.flush();
    Utilities.sleep(1500);
    if (range.getCell(3, 2).getValue() == "Done deletion") {
      /*
      var Avals = spreadsheet.getRange("A1:A").getValues();
      var lastRow = Avals.filter(String).length + 4;
      var lastRange = spreadsheet.getRange("A6"+":B"+lastRow);
      var colors = lastRange.getFontColors();
      */
      spreadsheet.deleteRow(result);
      spreadsheet.insertRowAfter(55 - 1);
      spreadsheet.getRange("D4:D4").clearContent();
      refresh();
      /*
      Utilities.sleep(1500);
      colors.splice(parseInt(result)-6,1);
      lastRange = spreadsheet.getRange("A6"+":B"+(lastRow-1));
      lastRange.setFontColors(colors);
      */
    }
  } else {
    spreadsheet.toast("Selected range should be 2 cells (time and name)");
  }
}

function binarySearch(query, range, firstIndex, lastIndex) {
  if (query < range[firstIndex - 1]) {
    SpreadsheetApp.getActive().getSheetByName('Booking (do not touch)').insertRowBefore(firstIndex);
    return firstIndex;
  }
  else if (query > range[lastIndex - 1]) {
    SpreadsheetApp.getActive().getSheetByName('Booking (do not touch)').insertRowAfter(lastIndex);
    return (lastIndex + 1);
  }
  else if (query == range[firstIndex - 1]) {
    return firstIndex;
  } 
  else if (query == range[lastIndex - 1]) {
    return lastIndex;
  }

  var middleIndex = Math.floor((lastIndex + firstIndex)/2);
  while(range[middleIndex - 1] != query && firstIndex < lastIndex)
  {
    if (query < range[middleIndex] - 1) {
      lastIndex = middleIndex - 1;
    }
    else if (query > range[middleIndex] - 1) {
      firstIndex = middleIndex + 1;
    }
    middleIndex = Math.floor((lastIndex + firstIndex)/2);
  }

  if (range[middleIndex - 1] == query) {
    return middleIndex;
  } else if (query < range[middleIndex - 1]) {
    SpreadsheetApp.getActive().getSheetByName('Booking (do not touch)').insertRowBefore(firstIndex);
    return firstIndex;
  }
  SpreadsheetApp.getActive().getSheetByName('Booking (do not touch)').insertRowAfter(lastIndex);
  return (lastIndex + 1);
}

function transposeArray(array){
  var result = [];
  for (var i = 0; i < array.length; i++) {
    result[i] = [];
    result[i][0] = array[i];
  }
  return result;
}

function storeAndApplyAttendance(oldDate, date) {
  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  var spreadsheet2 = SpreadsheetApp.getActive().getSheetByName('Booking (do not touch)');
  var searchRange = spreadsheet2.getRange("A:A").getValues();
  if (oldDate != "") {
    var index = binarySearch(oldDate, searchRange, 2, searchRange.length);
    var attendance = spreadsheet.getRange("E6:E").getValues().join("::");
    spreadsheet2.getRange(index, 1, 1, 2).setValues([[oldDate, attendance]]);
  }
  SpreadsheetApp.flush();

  searchRange = spreadsheet2.getRange("A:A").getValues();
  var index2 = binarySearch(date, searchRange, 2, searchRange.length);
  var attendance2 = spreadsheet2.getRange(index2, 2).getValue().toString();
  if (attendance2 == "") {
    attendance2 = "::";
  }
  spreadsheet2.getRange(index2, 1, 1, 2).setValues([[date, attendance2]]);
  var array = transposeArray(attendance2.split("::"));
  var fieldArrayLength = spreadsheet.getRange("E6:E").getValues().length;
  spreadsheet.getRange("E6:E").clearContent();
  if (array.length < fieldArrayLength) {
    spreadsheet.getRange("E6:E" + (5 + array.length)).setValues(array);
  } else if (array.length > fieldArrayLength) {
    spreadsheet.getRange("E6:E").setValues(array.slice(0, fieldArrayLength));
  } else {
    spreadsheet.getRange("E6:E").setValues(array);
  }
}


