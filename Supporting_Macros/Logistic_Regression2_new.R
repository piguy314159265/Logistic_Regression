suppressWarnings(library(AlteryxPredictive))

outer_config <- list(
  `graph.resolution` = dropdownInput('%Question.graph.resolution%' , '1x'),
  `Link` = dropdownInput('%Question.Link%' , 'logit'),
  `Model Name` = textInput('%Question.Model Name%'),
  `Use Weights` = checkboxInput('%Question.Use Weights%' , FALSE),
  `Weight Vec` = dropdownInput('%Question.Weight Vec%'),
  `X Vars` = listInput('%Question.X Vars%', c('AveDonAmt', 'DonPerYear', 'LastDonAmt', 'Region')),
  `Y Var` = dropdownInput('%Question.Y Var%', 'MonthGive'),
  regularization = checkboxInput('%Question.regularization%', FALSE),
  alpha = numericInput('%Question.alpha%', .5),
  lambda_1se = radioInput('%Question.lambda.1se%', TRUE),
  lambda_min = radioInput('%Question.lambda.min%', FALSE),
  standardize_pred = checkboxInput('%Question.standardize_pred%', TRUE),
  internal_cv = checkboxInput('%Question.internal_cv%', TRUE),
  set_seed_internal_cv = checkboxInput('%Question.set_seed_internal_cv%', TRUE),
  seed_internal_cv = numericInput('%Question.seed_internal_cv%', 1),
  nfolds = numericInput('%Question.nfolds%', 5),
  lambda_no_cv = numericInput('%Question.lambda_no_cv%', NULL),
  display_graphs = checkboxInput('%Question.display_graphs%', TRUE),
  external_cv = checkboxInput('%Question.external_cv%', TRUE),
  nfolds_external = numericInput('%Question.nfolds_external%', NULL),
  set_seed_external_cv = checkboxInput('%Question.set_seed_external_cv%', FALSE),
  external_seed_value = numericInput('%Question.external_seed_value%', NULL),
  `Omit Constant` = checkboxInput('%Question.Omit Constant%' , FALSE)
)



config <- list(
  `classification` = TRUE,
  `modelType` = NULL,
  `numberFolds` = numericInput('%Question.nfolds_external%' , 5),
  `numberTrials` = numericInput('%Question.numberTrials%' , 3),
  `posClass` = NULL,
  `regression` = FALSE,
  `stratified` = FALSE,
  `seed` = numericInput('%Question.seed%', 1)
)

config <- append(config, outer_config)

options(alteryx.wd = '%Engine.WorkflowDirectory%')
options(alteryx.debug = outer_config)

inputs <- list(
  data = read.Alteryx("#2"),
  models = list(model = unserializeObject((read.Alteryx("#1")$Object)[[1]]))
)

if (!(outer_config$regularization)) {
  mod.df <- read.Alteryx("#1")
  mod.obj <- unserializeObject(as.character(mod.df$Object[1]))
  the.class <- class(mod.obj)[1]
  write.Alteryx(data.frame(Class = the.class))
}

if (outer_config$external_cv) {
  if (is.null(getOption("testscript"))){
    inputs$models <- readModelObjects("#1", default = defaults$models)
    # saveRDS(inputs, "C:\\Users\\dblanchard\\Documents\\playground\\inputs.rds")
    # saveRDS(config, "C:\\Users\\dblanchard\\Documents\\playground\\config.rds")
    AlteryxPredictive::runCrossValidationLinReg(inputs, config)
  }
}

# dashboard <- AlteryxPredictive:::interactive_lm_report(
#   config = outer_config,
#   data = inputs$data,
#   model = inputs$models[[1]]
# )
# 
# flightdeck:::fdRender(
#   x = dashboard, 
#   nOutput = 5
# )