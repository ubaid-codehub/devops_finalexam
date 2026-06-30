
 FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci
FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build
RUN npm prune --omit=dev && npm cache clean --force
FROM gcr.io/distroless/nodejs20-debian12:nonroot AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=5000
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY index.js ./index.js
EXPOSE 5000
CMD ["index.js"]
