# \ -s puma

Dir.glob('./{models,helpers,controllers,services,values,forms}/*.rb')
  .each do |file|
  require file
end
run CanvasVisualizationApp
