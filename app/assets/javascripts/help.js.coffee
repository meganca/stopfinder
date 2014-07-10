showHelp = (fieldToShow) ->
  helpRow = document.getElementById(fieldToShow)
  helpImg = document.getElementById(fieldToShow + " image content")
  
  if helpRow.style.display == "none"
    helpRow.style.display = "table-row"
    
    if (/\/assets\/.+/.test(helpImg.src))
      document.getElementById(fieldToShow + " image link").innerHTML ="(display example image)"  
      
  else
    helpRow.style.display = "none"
    document.getElementById(fieldToShow + " image").style.display = "none"
    document.getElementById(fieldToShow + " image link").innerHTML = ""
  
showImage = (fieldToShow) ->
  imageRow = document.getElementById(fieldToShow + " image")
  helpImg = document.getElementById(fieldToShow + " image content")
  link = document.getElementById(fieldToShow + " image link")
  
  if imageRow.style.display == "none"
    imageRow.style.display = "table-row"
    link.innerHTML = "hide image"
    helpImg.style.display = "block"
  else
    imageRow.style.display = "none"
    link.innerHTML = "(display example image)"
    helpImg.style.display = "none"
      
updateHelpToShow = (fieldToShow, text, imgpath, imgalt) ->
  helpText = document.getElementById(fieldToShow + " help content")
  helpText.innerHTML = text
  
  helpImg = document.getElementById(fieldToShow + " image content")
  link = document.getElementById(fieldToShow + " image link")
  helpImg.src = "/assets/" + imgpath
  helpImg.alt = imgalt
  
  if imgpath != ""
    if link.innerHTML == ""
      link.innerHTML = "(display example image)"
  else
    document.getElementById(fieldToShow + " image").style.display = "none"
    link.innerHTML = ""
  
$ ->
  $("img[data-helptype]").click (e) ->
    e.preventDefault()
 
    fieldId = $(this).data("helptype")
    showHelp(fieldId)
    
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
 