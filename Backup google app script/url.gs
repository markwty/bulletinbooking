function onEdit(e){
  const rg = e.range;
  if (rg.isChecked()){
    if(rg.getSheet().getName() === "url" && rg.getA1Notation() === "C4"){
      send("summary");
      rg.uncheck();
    }
    else if(rg.getSheet().getName() === "events" && rg.getA1Notation() === "C4"){
      send("events");
      rg.uncheck();
    }
    else if(rg.getSheet().getName() === "extra" && rg.getA1Notation() === "C4"){
      send("extra");
      rg.uncheck();
    }
  }
}

String.prototype.replaceAll = function(search, replacement) {
        var target = this;
        return target.replace(new RegExp(search, 'g'), replacement);
};

function send(filename) {
  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  var range2 = spreadsheet.getRange("C3:C3");
  range2.getCell(1, 1).setFormula("");
  var lastRow = spreadsheet.getLastRow();
  var range = spreadsheet.getRange("A1:B"+lastRow);
  var values = range.getValues();
  var res = "";
  if (values[0].length == 2){
    for(var i = 2; i < values.length * 2; i+=2){
      if (values[i/2][0] == "") {
        continue;
      }
      var text = values[i/2][1].toString().replaceAll("\n","||");
      console.log(text);
      res = res + values[i/2][0]+"::"+text+"\\n";
    }
    var query = '"<insert url here>?txt=' + filename + '&data=' + res + '"';
    range2.getCell(1, 1).setFormula("IMPORTDATA(" + query + ")");
    SpreadsheetApp.flush();
    //range2.getCell(1, 1).setFormula("");
  }
}