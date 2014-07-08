showHelp = (fieldToShow) ->
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
      
updateHelpToShow = (fieldToShow, text, imgpath, imgalt) ->
  helpText = document.getElementById(fieldToShow + " help content")
  helpText.innerHTML = text
  helpImg = document.getElementById(fieldToShow + " image content")
  helpImg.src = "/assets/"+imgpath
  helpImg.alt = imgalt
  
$ ->
  $("img[data-helptype]").click (e) ->
    e.preventDefault()
 
    fieldId = $(this).data("helptype")
    showHelp(fieldId)
    
$ ->
  $("select[data-selecthelp]").change (e) ->
    e.preventDefault()
  
    selected = $(this).val()
    alert selected
    
 $ ->
  $("select[name^='busstop[']").change (e) ->
    e.preventDefault()
    
    field = $(this).attr('name').split(/[\[\]]/)
    text = $(this).find(':selected').data("help_text")
    img = $(this).find(':selected').data("help_img")
    imgalt = $(this).find(':selected').data("help_img_alt")
    
    updateHelpToShow(field[1], text, img, imgalt)
    
$ ->
  $("a[data-help-image]").click (e) ->
    e.preventDefault()
 
    fieldId = $(this).data("help-image")
    showImage(fieldId)
 