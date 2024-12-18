use clap::Parser;
use scraper::{Html, Selector};
use serde_json::Value;
use std::error::Error;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// Print version information for FRC PathPlanner
    #[arg(short, long)]
    path: bool,

    /// Print version information for WPILib
    #[arg(short, long)]
    wpi: bool,

    /// Print version information for NI FRC Game Tools
    #[arg(short, long)]
    ni: bool,

    /// Print version information for REV Hardware Client
    #[arg(short, long)]
    rhc: bool,

    /// Print version information for Choreo
    #[arg(short, long)]
    choreo: bool,

    /// Print URL for latest Git Windows release
    #[arg(short, long)]
    git: bool,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let args = Args::parse();
    let mut versions: Vec<String> = Vec::new();
    let mut version_sizes: Vec<f32> = Vec::new();
    let mut game_tools: Vec<String> = Vec::new();
    let mut game_tools_sizes: Vec<f32> = Vec::new();
    let mut pplib_versions: Vec<String> = Vec::new();
    let mut pplib_sizes: Vec<f32> = Vec::new();
    let mut rhc_versions: Vec<String> = Vec::new();
    let mut rhc_sizes: Vec<f32> = Vec::new();
    let mut choreo_versions: Vec<String> = Vec::new();
    let mut choreo_sizes: Vec<f32> = Vec::new();
    let mut git_url: String = String::new();
    let mut git_size: f32 = 0.0;
    if args.git {
        let client = reqwest::Client::new();
        let res = client.get("https://api.github.com/repos/git-for-windows/git/releases/latest")
            .header("User-Agent", "sponge2")
            .send()
            .await?;
        let release_json: Value = serde_json::from_str(res.text().await?.as_str()).unwrap();
        for asset in release_json["assets"].as_array().unwrap() {
            if asset["name"].to_string().contains("64-bit.exe") {
                git_url = asset["browser_download_url"].to_string().replace("\"", "");
                git_size = (asset["size"].as_i64().unwrap() / 1000) as f32;
                break;
            }
        }
    }
    if args.choreo {
        let client = reqwest::Client::new();
        let res = client
            .get("https://api.github.com/repos/SleipnirGroup/Choreo/releases")
            .header("User-Agent", "sponge2")
            .send()
            .await?;
        let release_json: Value = serde_json::from_str(res.text().await?.as_str()).unwrap();
        for release in release_json.as_array().unwrap() {
            if release["name"].to_string().contains("alpha")
                || release["name"].to_string().contains("beta")
            {
                continue;
            }

            for asset in release["assets"].as_array().unwrap() {
                if !asset["name"]
                    .to_string()
                    .to_lowercase()
                    .contains("windows-x86_64")
                    || !asset["name"].to_string().contains(".exe")
                {
                    continue;
                }

                choreo_versions.push(release["tag_name"].to_string().replace("\"", ""));
                choreo_sizes.push((asset["size"].as_i64().unwrap() / 1000) as f32);
            }
        }
    }
    if args.rhc {
        let client = reqwest::Client::new();
        let res = client
            .get("https://api.github.com/repos/REVrobotics/REV-Software-Binaries/releases")
            .header("User-Agent", "sponge2")
            .send()
            .await?;
        let release_json: Value = serde_json::from_str(res.text().await?.as_str()).unwrap();
        for release in release_json.as_array().unwrap() {
            if !release["tag_name"].to_string().contains("rhc")
                || release["tag_name"]
                    .to_string()
                    .to_lowercase()
                    .contains("beta")
                || release["tag_name"]
                    .to_string()
                    .to_lowercase()
                    .contains("alpha")
            {
                continue;
            }

            for asset in release["assets"].as_array().unwrap() {
                if !asset["name"].to_string().contains(".exe")
                    || asset["name"].to_string().contains("offline")
                {
                    continue;
                }

                rhc_versions.push(release["tag_name"].to_string().replace("\"", ""));
                rhc_sizes.push((asset["size"].as_i64().unwrap() / 1000) as f32);
            }
        }
    }
    if args.path {
        let client = reqwest::Client::new();
        let res = client
            .get("https://api.github.com/repos/mjansen4857/pathplanner/releases")
            .header("User-Agent", "sponge2")
            .send()
            .await?;
        let releases_json: Value = serde_json::from_str(res.text().await?.as_str()).unwrap();
        for release in releases_json.as_array().unwrap() {
            if release["tag_name"].to_string().contains("beta")
                || release["tag_name"].to_string().contains("alpha")
            {
                continue;
            }

            for asset in release["assets"].as_array().unwrap() {
                if asset["name"].to_string().contains("Windows") {
                    if release["tag_name"].to_string().as_str() == "\"2024.1.7\"" {
                        pplib_versions.push(
                            String::from("v")
                                + release["tag_name"].to_string().replace("\"", "").as_str(),
                        );
                    } else {
                        pplib_versions.push(release["tag_name"].to_string().replace("\"", ""));
                    }
                    pplib_sizes.push((asset["size"].as_i64().unwrap() / 1000) as f32);
                }
            }
        }
    }

    if args.ni {
        let game_tools_body = reqwest::get("https://packages.wpilib.workers.dev/game-tools/")
            .await?
            .text()
            .await?;
        let game_doc = Html::parse_document(&game_tools_body);
        for game_tr in game_doc.select(&Selector::parse("tr").unwrap()) {
            let inner_stuff = Html::parse_fragment(game_tr.inner_html().as_str());
            if inner_stuff.select(&Selector::parse("a").unwrap()).count() <= 0 {
                continue;
            }
            let title = game_tr
                .select(&Selector::parse("a[href]").unwrap())
                .collect::<Vec<_>>()
                .first()
                .unwrap()
                .inner_html();
            if !title.contains("ni") {
                continue;
            }
            game_tools.push(title);
            game_tools_sizes.push(
                game_tr
                    .select(&Selector::parse("td").unwrap())
                    .find(|e| e.text().collect::<Vec<_>>().join(" ").contains("GB"))
                    .unwrap()
                    .text()
                    .collect::<Vec<_>>()
                    .join(" ")
                    .replace(" GB", "")
                    .parse::<f32>()
                    .unwrap()
                    * 1e6,
            );
        }
    }

    if args.wpi {
        const URL: &str = "https://packages.wpilib.workers.dev/installer/";
        let body = reqwest::get(URL).await?.text().await?;
        let doc = Html::parse_document(&body);
        let tds = Selector::parse("td a[href]").unwrap();
        for td in doc.select(&tds) {
            let mut v = td.inner_html();
            if v.contains("alpha") || v.contains("beta") || v.contains("..") {
                continue;
            }
            v.retain(|c| c != '/');
            let body2 = reqwest::get((String::from(URL) + &v + "/Win64/").as_str())
                .await?
                .text()
                .await?;
            let file_table = Html::parse_document(&body2);
            for td2 in file_table.select(&Selector::parse("td").unwrap()) {
                let sizetxt = td2.text().collect::<Vec<_>>().join(" ");
                if sizetxt.ends_with("GB") {
                    version_sizes.push(sizetxt.replace(" GB", "").parse::<f32>().unwrap() * 1e6);
                }
            }
            versions.push(v);
        }
    }

    let mut ctr = 0;
    if args.wpi {
        print!(
            "{}{}",
            versions
                .iter()
                .map(|s| {
                    let res = s.to_owned() + "#" + version_sizes[ctr].to_string().as_str();
                    ctr += 1;
                    res
                })
                .collect::<Vec<_>>()
                .join("|"),
            if args.ni || args.path || args.rhc || args.choreo || args.git {
                "*"
            } else {
                ""
            }
        );
    }

    if args.ni {
        ctr = 0;
        print!(
            "{}{}",
            game_tools
                .iter()
                .map(|s| {
                    let res = s.to_owned() + "#" + game_tools_sizes[ctr].to_string().as_str();
                    ctr += 1;
                    res
                })
                .collect::<Vec<_>>()
                .join("|"),
            if args.path || args.rhc || args.choreo || args.git {
                "*"
            } else {
                ""
            }
        );
    }
    if args.path {
        ctr = 0;
        print!(
            "{}{}",
            pplib_versions
                .iter()
                .map(|s| {
                    let res = s.to_owned() + "#" + pplib_sizes[ctr].to_string().as_str();
                    ctr += 1;
                    res
                })
                .collect::<Vec<_>>()
                .join("|"),
            if args.rhc || args.choreo || args.git { "*" } else { "" }
        );
    }
    if args.rhc {
        ctr = 0;
        print!(
            "{}{}",
            rhc_versions
                .iter()
                .map(|s| {
                    let res = s.to_owned() + "#" + rhc_sizes[ctr].to_string().as_str();
                    ctr += 1;
                    res
                })
                .collect::<Vec<_>>()
                .join("|"),
            if args.choreo || args.git { "*" } else { "" }
        );
    }
    if args.choreo {
        ctr = 0;
        print!(
            "{}{}",
            choreo_versions
                .iter()
                .map(|s| {
                    let res = s.to_owned() + "#" + choreo_sizes[ctr].to_string().as_str();
                    ctr += 1;
                    res
                })
                .collect::<Vec<_>>()
                .join("|"),
            if args.git { "*" } else { "" }
        );
    }
    if args.git {
        print!("{}", git_url.to_owned() + "#" + git_size.to_string().as_str());
    }
    Ok(())
}
