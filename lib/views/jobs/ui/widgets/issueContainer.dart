import 'package:flutter/material.dart';
import 'package:resume_builder_app/views/jobs/models/jobissue_model.dart';

class issueContainer extends StatelessWidget {
  final GitHubIssue issue;
  final Function() onTap;

  const issueContainer(
      {super.key,
        required this.issue,
        required this.onTap
      });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5.0,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        ' ID:${issue.id}',
                        style: Theme.of(context).textTheme.titleSmall?.apply(
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        issue.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                      ),

                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            Text(
              issue.body,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.apply(color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 9),
          ],
        ),
      ),
    );
  }
}
