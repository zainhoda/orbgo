# ![orbgo](./orbgo.svg)

Beginnings of a Tableau-like front end for Python Pandas (Work In Progress)


![Orbgo Demo](https://media.giphy.com/media/AFg3h2TNzvFZ73PnIS/giphy.gif)

In my data analysis workflow I end up doing a lot of my exploratory analysis in Tableau and then mentally translating what I've done into Python Pandas so that I have fine-grained control over the calculations. 

The thought behind this project is to create a drag and drop interface like Tableau that generates Python Pandas code that can:
* Be copied and pasted into your own environment
* Possibly be a Jupyter plugin
* Run in a pay per use cloud environment

Additional Goals:
* Wizard to connect to various cloud data sources (like BigQuery)
* Interface to join data frames
* Arbitrary combinations and ordering of pivot tables, calculations, and joins
* Interface for various plotting options (subplots, layout, size, legend, colors, etc) -- this can use both the built-in plotting library as well as something like Plotly

Stretch Goals:
* Generate equivalent code for other languages/environments like:
    * Julia
    * Pandas-JS (to run in the browser)
    * WebAssembly (if someone creates a data frame library for it)
* Pick certain parameters as inputs to expose in a dashboard
    * Appropriate widgets for parameter types (checkboxes, dropdown, sliders)
    * Code generation that includes a web server
    * Possibly upload the data and code to an online gallery (Plotly has some of this functionality)


