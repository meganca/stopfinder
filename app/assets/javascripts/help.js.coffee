class Help  
  signposition_text = {"near side": "The bus stop is located on the first street named, before the intersection of the second, in the direction the bus travels."}
  samplevar = "WHY"
  @CONSTANT = 42
  hello: -> alert 'hello world'
  test: alertval -> alert signposition_text[alertval]
  
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
      
updateShow = (fieldToShow, selection) ->
  helpCell = document.getElementById(fieldToShow + " help text")
  helper = new Help
  helper.test("near side")
  alert helper.signposition_text["near side"]
  
$ ->
  $("img[data-helptype]").click (e) ->
    e.preventDefault()
 
    fieldId = $(this).data("helptype")
    show(fieldId)
    
$ ->
  $("select[data-selecthelp]").change (e) ->
    e.preventDefault()
  
    selected = $(this).val()
    alert selected
    
 $ ->
  $("select[name^='busstop[']").change (e) ->
    e.preventDefault()
    
    helpField = $(this).attr('name').split(/[\[\]]/)
    selection = $(this).val()
    updateShow(helpField[1], selection)
    
$ ->
  $("a[data-help-image]").click (e) ->
    e.preventDefault()
 
    fieldId = $(this).data("help-image")
    showImage(fieldId)
 