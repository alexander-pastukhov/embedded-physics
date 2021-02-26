#' Common plotting theme
#'
#' @return ggplot theme
#' @export
#'
#' @examples
#' ggplot() + plot_theme()
plot_theme <- function()
{
  theme(text=element_text(family="Arial"),
        axis.text.x = element_text(size = 8, colour = 'black'), 
        axis.text.y = element_text(size = 8, colour = 'black'), 
        axis.title.x = element_text(size = 10), 
        axis.title.y = element_text(size = 10), 
        panel.grid.minor.x = element_blank(), 
        panel.grid.minor.y =  element_line(size = 0.24), 
        axis.ticks = element_line(size = 0.24),
        plot.subtitle=element_text(size=8, hjust=0.5))
}


#' Compares models via LOO criterion and
#' computed mean and CI for intercept and
#' main effect.
#'
#' @param models Named list of fitted models with added LOO information criterion.
#' @param CI float, confidence interval, defaults to 0.89
#'
#' @return tibble with columns Model, dELPD, Weight, alpha, beta
#' @export
compare_models <- function(models, CI=0.89){
  # dELPD
  models_elpd <-  
    purrr::map(models, ~.$criteria$loo) %>%
    loo::loo_compare() %>%
    as_tibble(rownames = "Model") %>%
    mutate(dELPD=(sprintf("%.1f±%.2f", elpd_diff, se_diff))) %>%
    select(Model, dELPD)
  
  # weight
  models_weight <-
    purrr::map(models, ~.$criteria$loo) %>%
    loo::loo_model_weights() %>%
    data.matrix() %>%
    data.frame() %>%
    as_tibble(rownames = "Model") %>%
    mutate( Weight= (sprintf("%.2f", .)))%>%
    select(Model, Weight)
  
  # alpha per model
  models_alpha <-
    purrr::map_df(models, ~compute_model_alpha(., CI)) %>%
    t() %>%
    as_tibble(rownames = "Model") %>%
    rename(a = 2)
  
  # main effect per model
  models_beta <-
    purrr::map_df(models, ~compute_model_beta(., CI)) %>%
    t() %>%
    as_tibble(rownames = "Model") %>%
    rename(b = 2)
  
  purrr::reduce(list(models_elpd, models_weight, models_alpha, models_beta), dplyr::left_join, by="Model")
}


#' Computes estimate and CI for the main effect
#'
#' @param brms_model Fitted brms model
#' @param CI float, confidence interval, defaults to 0.89
#'
#' @return string
#' @export
compute_model_beta <- function(brms_model, CI=0.89){
  estimate <- 
    fixef(brms_model, probs = c((1-CI)/2, 1-(1-CI)/2)) %>%
    data.frame() %>%
    rownames_to_column("Coefficient") %>%
    rename(LowerCI=4, UpperCI=5) %>%
    filter(Coefficient %in% c("Term", "NotInteracting"))
  
  if (nrow(estimate) == 0){
    return("-")
  }
  
  sprintf('%.4f [%0.2f..%0.2f]', exp(estimate$Estimate), exp(estimate$LowerCI), exp(estimate$UpperCI))
}


#' Computes estimate and CI for the intercept
#'
#' @param brms_model Fitted brms model
#' @param CI float, confidence interval, defaults to 0.89
#'
#' @return string
#' @export
compute_model_alpha <- function(brms_model, CI=0.89){
  alpha <-
    fixef(brms_model,probs= c((1-CI)/2, 1-(1-CI)/2)) %>%
    data.frame()%>%
    rownames_to_column("Coefficient")%>%
    rename(LowerCI=4, UpperCI=5) %>%
    filter(Coefficient == "Intercept")
  
  sprintf('%.2f [%0.2f..%0.2f]',inv.logit(alpha$Estimate),
          inv.logit(alpha$LowerCI), inv.logit(alpha$UpperCI))
}



#' Computes pairwise estimate and CI for change in proportion between
#' baseline and other main effect levels.
#'
#' @param factor_model Fitted brms model with main effect as factor (categorical) variable.
#' @param CI Credible interval, defaults to 0.89.
#'
#' @return vector of character with ΔP estimates and CI for each pair. First value is "Control condition"
#' @export
compute_factor_level_predicted_difference <- function(factor_model, CI=0.89){
  predictions <- 
    predict(factor_model, 
            newdata = data.frame(TermAsFactor = sort(unique(factor_model$data$TermAsFactor))),
            summary = FALSE,
            re_formula = NA) 
  
  deltaP <- predictions[, -1] - predictions[, 1]
  
  dP <- 
    tibble(
      Estimate = apply(deltaP, MARGIN = 2, mean),
      LowerCI = apply(deltaP, MARGIN = 2, quantile, probs=(1-CI)/2),
      UpperCI = apply(deltaP, MARGIN = 2, quantile, 1-(1-CI)/2)) %>%
    mutate(Label = glue("ΔP={round(Estimate, 2)}\n{round(LowerCI, 1)}..{round(UpperCI, 1)}")) %>%
    pull(Label)
  
  c("Control\ncondition", dP)
}


#' Fits model prototype and add LOO and WAIC criteria, if required
#'
#' @param prototype Compiled brms model
#' @param data Data for fitting
#' @param add_loo logical, whether to add LOO and WAIC criteria
#'
#' @return Fitted brms model
#' @export
fit_prototype <- function(prototype, data, add_loo=TRUE){
  fit <- 
    update(prototype,
           newdata=data,
           refresh=0,
           cores=future::availableCores())
  
  if (add_loo){
    fit <- add_criterion(fit, "loo", reloo=TRUE)
    fit <- add_criterion(fit, "waic")
  }

  fit
}

