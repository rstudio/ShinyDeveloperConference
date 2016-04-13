# Principles of Reactivity

#### January 30, 2016

## Introduction

**[Slide]** Reactivity can be your best friend—or your worst enemy. If you follow some rules of the road, and trust them, then you'll end up moving in the right direction.

We haven't been very upfront about these rules; mostly I've disseminated them in replies to shiny-discuss threads. So even if you've been following Shiny development pretty closely, it's quite likely that some of the things I'll discuss today will be news to you.

One of my top priorities in 2016 is to get the message out there about how to use reactivity properly, and it starts right here, at this conference, in this tutorial. So your feedback is *most* welcome after the tutorial.

**[Slide]** You ignore these principles at your peril! The temptation is especially strong among smart, experienced programmers. Resist it—at least until you've tried to do it the right way first. These aren't rules that people say but don't expect anyone to completely follow, like "write unit tests for every function", "floss after every meal", etc. These are more like, "bring your car to a stop when you come to a stop sign".

**[Slide: red phone]** If you've tried to do it the right way and still really want to break these rules, email me at joe@rstudio.com and let's talk about it. But please, do that before sinking weeks or months into your app, while I can still help you!

## Our goal today

I'd like to propose a ladder of Shiny reactivity "enlightenment".

**[Slide]**

1. Made it halfway through the tutorial. Has used `output` and `input`.
2. Made it entirely through the tutorial. Has used reactive expressions (`reactive()`).
3. Has used `observe()` and/or `observeEvent()`. Has written reactive expressions that depend on other reactive expressions. Has used `isolate()` properly.
4. Can say confidently when to use `reactive()` vs. `observe()`. Has used `invalidateLater`.
5. Writes higher-order reactives (functions that have reactive expressions as input parameters and return values).
6. Understands that reactive expressions are monads.

**[Interactive: 3 minutes]** Take a moment to read this list, then discuss with the people around you where you currently rank. Don't be shy or embarrassed if you're at level one or two, we're all here to learn! Go ahead, I'll give you three minutes.

How many of you feel like you're at levels one or two?

How many are at level three?

How many are at level four?

Anyone besides Hadley and Winston at five or six?

So at level three, you can write quite complicated applications. And many of you have. **[Slide]** This is almost like a danger zone. Your apps generally work, but sometimes you struggle with why things are executing too much, or not enough. Each new feature you add to your app seems to increase the overall complexity superlinearly.

Our goal today is to get everyone, or at least most of you, to level four. When you have a firm grasp on the reactive primitives we've built into Shiny, you can build complicated networks of reactive expressions and observers, with confidence. Combine that knowledge with the new modules feature, which Garrett will talk about tomorrow, and you've got all the tools you need to write large yet maintainable Shiny apps.

Level five or six is where the real fun begins. We won't get there today, but if you're interested in learning more, please let me know! I'd love to talk to you. Maybe we can organize a group vchat or webinar or something, and eventually spin that in to an article or three.

## Reactivity by example

We'll get started with a really basic example app, just to get the juices flowing a little bit.

### Exercise 1: Basic output declaration

**Concept:** An output assignment is not an *order* to *update* the output. It's a *recipe* that *describes* how the output should be updated. The *when* is Shiny's job to think about.

**Exercise:** output$foo <- renderPlot( ... input$x ... )

**Anti-pattern:** observe(output$foo <- renderXXX(...)).

Open up Exercise_01.R; it should be in your Files pane. You should see the beginnings of a Shiny app. The UI definition is complete, but the server function is blank. I want you to fill in that server function. Make the plot output show a simple plot of the first `nrows` rows of a built-in dataset of your choice. If you can't think of any, use `cars`.

So basically, make the Shiny equivalent of this: `plot(head(cars, nrows))`

I'll give you five minutes. That might be way too much for some of you, but it'll give us a chance to shake out any technical issues. If you need help, talk to your neighbors, or flag down one of the TAs or myself. If you have extra time, get to know your neighbors a little more.

**[Slide: 5 minute countdown]**

OK, we're back. Hopefully your code looks something like this:

**[Slide: Solution_02.R]**

``` 
output$plot <- renderPlot({
  plot(head(cars, input$nrows))
})
```

How many of you ended up with this answer? Anyone come up with something different?

What we don't want is something like this:

``` 
observe({
  df <- head(cars, input$nrows)
  output$plot <- renderPlot(plot(df))
})
```

This pattern of putting renderPlot inside of an observe, usually means the author has a fundamental misconception of what it means to assign a render code block to an output slot.

**[Slide]**

`output$plot <- renderPlot(...)`

_What this DOESN'T mean:_ Go ahead and update the "plot" output with the result of this expression.

_What this DOES mean:_ This is the _recipe_ that should be used to update the "plot" output. I trust you (Shiny) to decide if and when it needs to be executed.

#### Sidebar A: How does it work?

Historically, we've asked you to take it on faith that whenever `input$nrows` changes, any dependent outputs, reactive expressions, and observers will do the right thing. But how does Shiny know how the code is related? How does it know which outputs depend on which inputs, reactives, etc.?

There are really two possibilities: _static_ analysis, where we'd examine your code, looking for reactive-looking things; and _runtime_ analysis, where we'd execute your code and see what happens.

### Exercise 2: Use reactive expressions for calculation reuse

**Concept:** They are cached and lazy. (What if you want cached and eager? *Call it from an observer.*) (What if you want non-cached and lazy? *That's what a function is.*) (What if you want non-cached and eager? *Make a function, and call it from an observer. But that doesn't make sense.*)

**Exercise:** Add table.

**Anti-pattern:** Using reactiveValues (or worse, a variable) with an observer.

For Exercise 2, you can either start from your solution for Exercise 1, or you can open up the file Exercise_02.R. It doesn't really matter.

In this exercise, add a `tableOutput("table")` to ui.R and have it show the same data that is being plotted. But make sure that the `head()` operation isn't performed more than once for each change to `input$nrows`.

Let's go for five minutes again.

**[Slide: 5 minute countdown]**

How'd we do? Was everyone successful?

Here's one answer:

``` 
df <- reactive(head(cars, input$nrows))
output$plot <- renderPlot(plot(df()))
output$table <- renderTable(df())
```

Who had something similar?

---

#### Sidebar B: Observer madness

Did anyone end up using an observer, like this?

``` 
values <- reactiveValues(df = cars)
observe({ values$df <- head(cars, input$nrows) })
output$plot <- renderPlot(plot(values$df))
output$table <- renderTable(values$df)
```

Or how about this (which doesn't work):

``` 
df <<- cars
observe({
  df <<- head(cars, input$nrows)
})
output$plot <- renderPlot(plot(df))
output$table <- renderTable(df)
```

Let's forget about that last one, since it doesn't work. What about the previous two? Let's talk about what they do. The first one uses a reactive expression to store the calculation. The second one creates a reactive values object and uses an observer to keep the value up-to-date. Who prefers the first approach? Who prefers the second?

So we mostly agree that the first approach is superior. But why? It might feel like I'm just setting up strawmen, but I see this kind of code all the time on the shiny-discuss mailing list. It seems obvious when we lay it bare with a minimal example like this, but in the context of a more complicated app, it can be much trickier.

We shouldn't take the second approach—but *why* shouldn't we take it? What's the first-principles reason to avoid this kind of code? We need some first-principles to build from so we can confidently answer these questions. You should be able to confidently answer these questions by the end of the tutorial.

### Basic dependency tracking (maybe not an exercise)

**Concept:** It's magic, but "good magic". Tracking happens by eavesdropping (of reactive values and reactive expressions)—Shiny pays attention when these are read.

**Exercise:** Make an app with two inputs and two outputs.

### Exercise 3: Use observe (or observeEvent) for side effects

**Concept:** Know the difference between calculations and actions. Very important distinction!

**Exercise:** TODO

**Anti-pattern:** Side effects in reactive expressions or outputs! Yuck! Show how tabs can prevent reactive expressions from being invoked.

(Consider multiple examples)

#### Sidebar C: Reactive expressions vs. Observers

What exactly is this thing we created with `reactive()`? What properties does it have?

**[slide]**

1. It **can be called** and **returns a value**, like a function. Either the last expression, or `return()`.
2. It's **lazy**. It doesn't execute its code until somebody calls it. Also like a function.
3. It's **cached**. The first time it's called, it executes the code and saves the resulting value. Subsequent calls can skip the execution and just return the value.
4. It's **reactive**. It is notified when its dependencies change. When that happens, it clears its cache and notifies it dependents.

**[slide]** The fact that it's **lazy** and **caches** are critical. It's _hard to reason about_ how often reactive expressions will execute their code, or even whether they will execute them at all.

Now what does an `observe()` look like?

**[slide]**

1. It **can't be called** and **doesn't return a value**. The value of the last expression will be thrown away, as will values passed to `return()`.
2. It's **eager**. After it's created, it executes (not right at that instant, but ASAP).
3. (Since it can't be called and doesn't have a return value, there's no notion of caching that applies here.)
4. It's **reactive**. It is notified when its dependencies change, and when that happens it executes (not right at that instant, but ASAP).

OK, let's compare the two.

**[slide with table]**

Don't worry, there won't be a quiz on this. All of this is to point the way towards the two things you _do_ need to remember.

This next slide is the reason I wanted to have this conference in the first place.

Are you ready?

**[slide]**

`reactive()` is for *calculating values, without side effects*.

`observe()` is for *performing actions, with side effects*.

**[/slide]**

This is what each of these is good for. Do not use an `observe` when calculating a value, and especially don't use `reactive` for performing actions with side effects.

**[slide]** Calculation or action???

A calculation is a block of code where you don't care about whether the code actually executes—you just want the answer. Safe for caching.

An action is where you care very much that the code executes, and there is no answer.

(What if you want both an answer AND you want the code to execute? Refactor into two code chunks--separate the calculation from the action.)

**[slide]** Keep your side effects / Outside of your reactives / Or I will kill you

### Exercise 4: Use reactiveValues to track values that cannot be derived

**Concept:** Use them only when a reactive expression can't capture what you need. Usually you'll use an observer.

**Exercise:** Accumulating data points that a user is adding or excluding by clicking on a plot.

**Anti-pattern:** Using non-reactive values (i.e. normal variables and <<-).

We've identified a number of cases where we should use a reactive expression instead of an `observe(Event)`/`reactiveValues` pairing. But there are cases where you simply *must* use the latter.

- **Accumulating** values over time, not just reacting to the latest one
- **Aggregating** multiple reactive values/expressions into a single expression
- Adding **artificial latency** into reactive values/expressions

These are essentially cases where inputs, outputs, and reactive expressions aren't powerful enough to natively express the computations you want to perform. So you have the "escape hatch" of `observe`/`reactiveValues`; you can do things that would otherwise be impossible, at the price of your code being harder to reason about and harder for the reactive framework to help you with.

### Exercise 5: Use reactiveValues to track values that cannot be derived (part 2)

Concept:

Exercise:

Anti-pattern:

---

Now we have covered three fundamental units of reactivity: state (reactiveValues), calculations (reactive expressions), actions (observers). With these three pieces, we now have our first complete picture of reactivity.

> Reactivity tracks **changing state** so that the appropriate **actions** can be taken automatically. In doing so, we specify **calculations** that represent intermediate values. The ideal reactive program always executes **necessary actions** while performing the **minimum number of calculations**. The framework accomplishes this by automatically **tracking dependencies**.

There are two pieces we haven't covered: `isolate` and `invalidateLater`. Once we have those two pieces, everything else is accomplished by combining these five primitives:

* `reactiveValues()`
* `reactive()`
* `observe()`
* `isolate()`
* `invalidateLater()`

Here are just some of the things we can accomplish.

* `input`
* `output`/`render`
* `validate` and `req`
* `debounce` (see gist)
* `shinySignals` (https://github.com/hadley/shinySignals)
* `invokeLater` (see gist)
* `observeEvent`, `eventReactive`

---

### Exercise 6: Use eventReactive to restrict when calculations invalidate

**Concept:** Tie expensive calculations to action buttons.

**Exercise:**

**Anti-pattern:** Using observeEvent and reactiveValues.

Let's go back and take a look at `observe` and `observeEvent`. They're both used for actions, that is to say, side effects. They differ in that `observe` _implicitly_ takes a reactive dependency on everything it reads—a change in anything will cause it to re-execute—while `observeEvent` only re-executes based on what you _explicitly_ tell it to.

* Action, implicit reactivity: `observe`
* Action, explicit reactivity: `observeEvent`
* Calculation, implicit reactivity: `reactive`
* Calculation, explicit reactivity: `eventReactive`

Similarly, `eventReactive` is for declaring calculations that only invalidate based on what you _explicitly_ tell it to. 99% of the time, it's going to be action buttons.

### Exercise 7: Checking preconditions with req

**Concept:** `req` is a lightweight way to achieve cascading stopping of executions, that aren't error conditions.

**Exercise:**

**Anti-pattern:**

### invalidateLater

**Concept:** Use for anything that might change in the "real world" but not have any inherent effect on reactivity on its own.

**Exercise:**

**Anti-pattern:** Just using non-reactive things and expecting them to behave reactively.

### Higher order reactives (bonus)

**Concept:** Use reactive expressions as the primary unit to compute on, when writing higher-order reactives. Inputs and outputs should both be reactive expressions.