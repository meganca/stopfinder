show = (fieldToShow) ->
  helpRow = document.getElementById(fieldToShow)
  if helpRow.style.display == "none"
    helpRow.style.display = "table-row"
  else
    helpRow.style.display = "none"
    helpImg = document.getElementById(fieldToShow+" image")
    helpImg.style.display = "none"
    document.getElementById(fieldToShow + " image link").innerHTML ="(display example image)"
  
showImage = (fieldToShow) ->
  imageRow = document.getElementById(fieldToShow)
  if imageRow.style.display == "none"
    imageRow.style.display = "table-row"
    document.getElementById(fieldToShow + " link").innerHTML ="hide image"
  else
    imageRow.style.display = "none"
    document.getElementById(fieldToShow + " link").innerHTML ="(display example image)"
  
$ ->
  $("img[data-helptype]").click (e) ->
    e.preventDefault()
 
    fieldId = $(this).data("helptype")
    show(fieldId)
    
$ ->
  $("a[data-help-image]").click (e) ->
    e.preventDefault()
 
    fieldId = $(this).data("help-image")
    showImage(fieldId)
 