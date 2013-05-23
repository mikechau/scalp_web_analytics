jQuery ->
  $("#time_input_start, #time_input_end, #time_input_start2, #time_input_end2").datetimepicker
    controlType: "select"
    dateFormat: "yy-mm-dd"
    timeFormat: "HH:mm:ss"

  $("#time_input_start3, #time_input_end3").datepicker
    dateFormat: "yy-mm-dd"