# \ -s puma

Dir.glob('./{controllers,services,models,helpers,values}/*.rb')
  .each do |file|
  require file
end
run CanvasLmsAPI
