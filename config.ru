# \ -s puma

Dir.glob('./{helpers,models,controllers,services,values}/*.rb')
  .each do |file|
  require file
end
run CanvasLmsAPI
