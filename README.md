# xtractoMatlab
Matlab Version of xtractomatic package

`xtractoMatlab` contains <span style="color:blue">Matlab</span> functions developed to subset and extract satellite and other oceanographic related data from a remote server. The program can extract data for a moving point in time along a user-supplied set of longitude, latitude and time points; in a 3D bounding box; or within a polygon (through time).  The `xtractoMatlab` functions were originally developed for the marine biology tagging community, to match up environmental data available from satellites (sea-surface temperature, sea-surface chlorophyll, sea-surface height, sea-surface salinity, vector winds) to track data from various tagged animals or shiptracks (`xtracto`). The package has since been extended to include the routines that extract data a 3D bounding box (`xtracto_3D`) or within a polygon (`xtractogon`).  The `xtractoMatlab`  package accesses  data that are served through the <span style="color:blue">ERDDAP</span> (Environmental Research Division Data Access Program) server at the NOAA/SWFSC Environmental Research Division in Santa Cruz, California. The <span style="color:blue">ERDDAP</span> server can also be directly accessed at <http://coastwatch.pfeg.noaa.gov/erddap>. <span style="color:blue">ERDDAP</span> is a simple to use yet powerful web data service developed by Bob Simons.  

To download either clone using Git, or just click on the button to download a zip of the files. Requires a version of Matlab that supports webread, websave and weboptions.  The file `vignette.m` contains code that executes all of the examples in the R <span style="color:blue">xtractomatic</span> package ( <https://github.com/rmendels/xtractomatic>).

# Required legalese

“The United States Department of Commerce (DOC) GitHub project code is provided
on an ‘as is’ basis and the user assumes responsibility for its use.
DOC has relinquished control of the information and no longer has responsibility
to protect the integrity, confidentiality, or availability of the information.
Any claims against the Department of Commerce stemming from the use of its
GitHub project will be governed by all applicable Federal law. Any reference to
specific commercial products, processes, or services by service mark, trademark,
manufacturer, or otherwise, does not constitute or imply their endorsement,
recommendation or favoring by the Department of Commerce. The Department of
Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used
in any manner to imply endorsement of any commercial product or activity by DOC
or the United States Government.”

