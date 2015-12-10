$ ->
  $("#doc").change ->
    upload = $("#doc").val().split("\\").pop()

    abort = false
    $("#tree li").each (i,file) ->
      if $(file).text() == upload
        if $(file).hasClass "directory"
          alert "A directory with that name already exists."
          $("#doc").val('')
          return abort = true
        else if !confirm('File already exists. Overwrite?')
          $("#doc").val('')
          return abort = true

    $("#submit").click()
