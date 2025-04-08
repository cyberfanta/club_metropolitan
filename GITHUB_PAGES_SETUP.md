# GitHub Pages Setup Instructions

Follow these steps to set up GitHub Pages for your Club Metropolitan project:

## 1. Push the code to GitHub

If you haven't already, push the latest code to GitHub:

```bash
git add .
git commit -m "Add GitHub Pages deployment"
git push origin main
```

## 2. Configure GitHub Repository Settings

1. Go to your GitHub repository page
2. Click on "Settings" tab
3. In the left sidebar, click on "Pages"
4. Under "Build and deployment" section:
   - Source: Select "GitHub Actions"
   - This will use the deployment workflow we've added to the repository

## 3. Run the Workflow Manually (Optional)

For the first deployment, you can manually trigger the workflow:

1. Go to the "Actions" tab in your repository
2. Select the "Deploy to GitHub Pages" workflow
3. Click on "Run workflow" button and choose the main branch

## 4. Verify Deployment

1. Once the workflow completes, you should see a green checkmark by the action
2. Your site will be published at: `https://cyberfanta.github.io/club_metropolitan/`
3. The badge in the README.md will also show the deployment status

## Troubleshooting

If you encounter any issues:

1. Check the Actions tab for any error messages
2. Make sure you've enabled GitHub Pages in your repository settings
3. Verify that your repository is public or that you have GitHub Pro for private repository Pages

## Future Updates

Whenever you push changes to the main branch, GitHub Actions will automatically:
1. Build your Flutter web application
2. Deploy it to the gh-pages branch
3. Update your GitHub Pages site with the new version 