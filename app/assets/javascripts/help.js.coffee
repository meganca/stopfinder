showHelp = (fieldToShow) ->
  helpRow = document.getElementById(fieldToShow)
  helpImg = document.getElementById(fieldToShow + " image content")
  
  if helpRow.style.display == "none"
    helpRow.style.display = "table-row"
  else
    helpRow.style.display = "none"
    helpImg = document.getElementById(fieldToShow+" image")
    helpImg.style.display = "none"
    document.getElementById(fieldToShow + " image link").innerHTML ="(display example image)"
  
  if helpImg.src
    if !(/\/assets\/.+/.test(helpImg.src))
      document.getElementById(fieldToShow + " image link").innerHTML =""
    else
      document.getElementById(fieldToShow + " image link").innerHTML ="(display example image)"
  
showImage = (fieldToShow) ->
  imageRow = document.getElementById(fieldToShow)
  helpImg = document.getElementById(fieldToShow + " image content")
  link = document.getElementById(fieldToShow + " link")
  
  if imageRow.style.display == "none"
    imageRow.style.display = "table-row"
    document.getElementById(fieldToShow + " link").innerHTML ="hide image"
    helpImg.style.display = "block"
  else
    imageRow.style.display = "none"
    document.getElementById(fieldToShow + " link").innerHTML ="(display example image)"
    
  if helpImg
    if !(/\/assets\/.+/.test(helpImg.src))
      helpImg.style.display = "none"
      document.getElementById(fieldToShow + " image link").innerHTML =""
      
updateHelpToShow = (fieldToShow, text, imgpath, imgalt) ->
  helpText = document.getElementById(fieldToShow + " help content")
  helpText.innerHTML = text
  helpImg = document.getElementById(fieldToShow + " image content")
  if !!imgpath
    helpImg.src = "/assets/"+imgpath
    helpImg.alt = imgalt
    helpImg.style.display = "block"

    if document.getElementById(fieldToShow + " image link").innerHTML == "hide image"
      document.getElementById(fieldToShow + " image link").innerHTML = "hide image"
    else
      document.getElementById(fieldToShow + " image link").innerHTML = "(display example image)"
  else
    helpImg.style.display = "none"
    document.getElementById(fieldToShow + " image link").innerHTML =""
  
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
 