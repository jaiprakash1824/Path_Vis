import os
from os import makedirs
from os.path import join, splitext, basename, isfile
from multiprocessing import Pool
from functools import partial
import argparse
import ast

import h5py
import openslide
import numpy as np
import pandas as pd
from cv2 import filter2D
from tqdm import tqdm
from sklearn.cluster import KMeans

from processing import prepare_slide, extract_features
from search import main_search


parser = argparse.ArgumentParser(description="segmenting and patching")

parser.add_argument("--query_slide_path", type=str, help="Path to the query slide.")
parser.add_argument("--metadata_path", type=str, default="/home/data/yottixel/DATABASE/sampled_metadata.csv", help="Path to the metadata .csv file.")
parser.add_argument("--database_dir", type=str, default="/home/data/nejm_ai/DATABASE/", help="Address where the database is stored.")
parser.add_argument("--database_features_path", type=str, default="/home/data/yottixel/DATABASE/features.pkl", help="Path to the extracted database features.")
parser.add_argument("--query_extension", type=str, default="svs", help="Extension of the query slide.")
parser.add_argument("--k", type=int, default=5, help="Number of retrieved results.")
parser.add_argument("--subtype_search", action='store_true', help="Provide this flag if you want to perform subtype search.")
parser.add_argument("--query_site", type=str, default=None, help="If subtype_search is selected, you should provide either ['brain', 'breast', 'lung', 'colon', 'liver'] for this input.")
parser.add_argument("--save_dir", type=str, default="./Results", help="Address of the directory the results would be saved in.")
parser.add_argument("--tissue_threshold", type=float, default=0.7, help="For a patch to be considered, it should have this much tissue area.")
parser.add_argument("--kmeans_clusters", type=int, default=9, help="Number of clusters for RGB clustering.")
parser.add_argument("--percentage_selected", type=float, default=15, help="Percentage of patches within each RGB cluster to be spatially selected.")
parser.add_argument('--use_gpu', type=bool, default=True, help='Whether to use GPU')
parser.add_argument('--network_weights_address', default='./checkpoints/KimiaNetKerasWeights.h5', help='Address of network weights')
parser.add_argument('--network_input_patch_width', type=int, default=1000, help='Width of network input patch')
parser.add_argument('--batch_size', type=int, default=1024, help='Batch size')
parser.add_argument('--img_format', default='png', help='Patch image format')

def run(query_slide_path_input, ):
    query_slide_path = query_slide_path_input
    metadata_path = args.metadata_path
    database_dir = args.database_dir
    database_features_path = args.database_features_path
    query_extension = args.query_extension
    k = args.k
    subtype_search = args.subtype_search
    query_site = args.query_site
    save_dir = "./outputs"
    tissue_threshold = args.tissue_threshold
    kmeans_clusters = args.kmeans_clusters
    percentage_selected = args.percentage_selected
    use_gpu = args.use_gpu
    network_weights_address = args.network_weights_address
    network_input_patch_width = args.network_input_patch_width
    batch_size = args.batch_size
    img_format = args.img_format

if __name__ == "__main__":
    args = parser.parse_args()

    query_slide_path = args.query_slide_path
    metadata_path = args.metadata_path
    database_dir = args.database_dir
    database_features_path = args.database_features_path
    query_extension = args.query_extension
    k = args.k
    subtype_search = args.subtype_search
    query_site = args.query_site
    save_dir = args.save_dir
    tissue_threshold = args.tissue_threshold
    kmeans_clusters = args.kmeans_clusters
    percentage_selected = args.percentage_selected
    use_gpu = args.use_gpu
    network_weights_address = args.network_weights_address
    network_input_patch_width = args.network_input_patch_width
    batch_size = args.batch_size
    img_format = args.img_format

    if use_gpu:
        os.environ['NVIDIA_VISIBLE_DEVICES'] = '0'
        os.environ['CUDA_VISIBLE_DEVICES'] = '0'
    else:
        os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
        os.environ["CUDA_VISIBLE_DEVICES"] = "-1"

    prepare_slide(query_slide_path, save_dir, tissue_threshold, kmeans_clusters, percentage_selected)
    extract_features(query_slide_path, save_dir, network_weights_address, network_input_patch_width, batch_size, img_format)
    print(main_search(query_slide_path, save_dir, database_dir, database_features_path, metadata_path, query_extension, k, subtype_search, query_site))
        