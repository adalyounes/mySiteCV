## Base ########################################################################
# Use a larger node image to do the build for native deps (e.g., gcc, python)
FROM node:lts as base

# Reduce npm log spam and colour during install within Docker
ENV NPM_CONFIG_LOGLEVEL=warn
ENV NPM_CONFIG_COLOR=false

# We'll run the app as the `node` user, so put it in their home directory
WORKDIR C:\Users\usr\my-website
# Copy the source code over
COPY --chown=node:node . C:\Users\usr\my-website

## Development #################################################################
# Define a development target that installs devDeps and runs in dev mode
FROM base as development
WORKDIR C:\Users\usr\my-website
# Install (not ci) with dependencies, and for Linux vs. Linux Musl (which we use for -alpine)
RUN npm install
# Switch to the node user vs. root
USER node
# Expose port 3000
EXPOSE 3000
# Start the app in debug mode so we can attach the debugger
CMD ["npm", "start"]

## Production ##################################################################
# Also define a production target which doesn't use devDeps
FROM base as production
WORKDIR C:\Users\usr\my-website
COPY --chown=node:node --from=development C:\Users\usr\my-website\node_modules C:\Users\usr\my-website\node_modules
# Build the Docusaurus app
RUN npm run build

## Deploy ######################################################################
# Use a stable nginx image
FROM nginx:stable-alpine as deploy
WORKDIR C:\Users\usr\my-website
# Copy what we've installed/built from production
COPY --chown=node:node --from=production C:\Users\usr\my-website\build C:\Users\usr\my-website\filedo