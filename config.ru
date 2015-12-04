# \ -s puma

Dir.glob('./{config,models,helpers,controllers,services,values}/*.rb')
  .each do |file|
  require file
end
run CanvasLmsAPI
